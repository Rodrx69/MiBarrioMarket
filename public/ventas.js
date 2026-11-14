//========= OBTENER LOS ELEMENTOS DE LA PAGINA =============

const selectorCategoria = document.getElementById("categoria-venta");
const descripcionCategoria = document.getElementById("descripcion-categoria-venta");
const listaProductos = document.getElementById("lista-productos-venta");
const buscarProducto = document.getElementById("buscar-producto");
const carritoVenta = document.getElementById("carrito-venta");
const cantidadProductos = document.getElementById("cantidad-productos");
const totalVenta = document.getElementById("total-venta");
const mensajeVenta = document.getElementById("mensaje-venta");
// Elementos para los datos del cliente
const selectorComprobante = document.getElementById("comprobante-venta");
const camposClienteVenta = document.getElementById("campos-cliente-venta");

//========= VARIABLES DEL SISTEMA ==========

    //======== CAMBIAR CAMPOS SEGUN EL COMPROBANTE ========
    function mostrarCamposCliente() {
        // Obtener el tipo de comprobante seleccionado
        const comprobante = selectorComprobante.value;
        // Si selecciona FACTURA
        if (comprobante === "2") {
            camposClienteVenta.innerHTML = `
                <label for="ruc-cliente">RUC</label>
                <input
                    type="text"
                    id="ruc-cliente"
                    maxlength="11"
                    inputmode="numeric"
                    placeholder="Ingrese RUC"
                >
                <label for="razon-social-cliente">Razon social</label>
                <input
                    type="text"
                    id="razon-social-cliente"
                    placeholder="Ingrese razon social"
                >
            `;
        } else {
            // Si selecciona BOLETA o TICKET
            camposClienteVenta.innerHTML = `
                <label for="dni-cliente">DNI</label>
                <input
                    type="text"
                    id="dni-cliente"
                    maxlength="8"
                    inputmode="numeric"
                    placeholder="Ingrese DNI"
                >
                <label for="nombre-cliente">Nombres</label>
                <input
                    type="text"
                    id="nombre-cliente"
                    placeholder="Ingrese nombres"
                >
                <label for="apellido-cliente">Apellidos</label>
                <input
                    type="text"
                    id="apellido-cliente"
                    placeholder="Ingrese apellidos"
                >
            `;
        }
    }
    // Guardar los productos de la categoria seleccionada
    let productosActuales = [];
    // Guardar los productos agregados al carrito
    const carrito = new Map();
    // Formato de moneda peruana
    const formatoMoneda = new Intl.NumberFormat("es-PE", {
        style: "currency",
        currency: "PEN"
    });
    // Guardar el boton del ultimo comprobante generado
    let botonComprobanteAnterior = null;

    //============ MOSTRAR FECHA Y HORA ==============

    function actualizarFechaHora() {
        // Obtener la fecha y hora actual
        const ahora = new Date();
        // Mostrarla en formato peruano
        document.getElementById("fecha-hora-venta").textContent =
            ahora.toLocaleString("es-PE", {
                dateStyle: "medium",
                timeStyle: "medium"
            });
    }
    // Actualizar la hora cada segundo
    actualizarFechaHora();
    setInterval(actualizarFechaHora, 1000);

// Solicita a la API las categorias que el servidor lee de SQL Server.

async function cargarCategorias() {
    try {
        // Pide las categorias al servidor; el navegador no accede directamente a SQL Server.
        const respuesta = await fetch("/api/categorias");
        // Convertir la respuesta a JSON
        const resultado = await respuesta.json();
        // Comprobar si la consulta fue correcta
        if (!respuesta.ok || !resultado.correcto) {
            throw new Error("No se pudieron cargar las categorias.");
        }
        // Limpiar el selector
        selectorCategoria.innerHTML = "";
        // Crear la opcion inicial
        const opcionInicial = document.createElement("option");
        opcionInicial.value = "";
        opcionInicial.textContent = "Seleccionar categoria";
        selectorCategoria.appendChild(opcionInicial);
        // Recorrer las categorias recibidas
        resultado.categorias.forEach(function(categoria) {
            const opcion = document.createElement("option");
            opcion.value = categoria.ID_CATEGORIA;
            opcion.textContent = categoria.NOMBRE_CATEGORIA;
            // Guardar la descripcion de la categoria
            opcion.dataset.descripcion = categoria.DESCRIP_CATEGORIA;
            selectorCategoria.appendChild(opcion);
        });
    } catch (error) {
        console.error("Error al cargar categorias:", error.message);
        selectorCategoria.innerHTML =
            '<option value="">Error al cargar categorias</option>';
    }
}

// Solicita al servidor los productos y el stock disponible de una categoria.

async function cargarProductos(idCategoria) {
    try {
        // Mostrar mensaje de carga
        listaProductos.textContent = "Cargando productos...";
        // La API consulta SQL Server y devuelve los productos de la categoria seleccionada.
        const respuesta = await fetch(
            "/api/productos/" + encodeURIComponent(idCategoria)
        );
        // Convertir la respuesta a JSON
        const resultado = await respuesta.json();
        if (!respuesta.ok || !resultado.correcto) {
            throw new Error("No se pudieron consultar los productos.");
        }
        // Guardar los productos recibidos
        productosActuales = resultado.productos;
        // Mostrar los productos
        mostrarProductos();
    } catch (error) {
        console.error("Error al cargar productos:", error.message);
        listaProductos.textContent =
            "No se pudieron cargar los productos.";
    }
}
// ======== MOSTRAR LOS PRODUCTOS EN LA PANTALLA ===========

function mostrarProductos() {
    // Obtener el texto de busqueda
    const textoBusqueda = buscarProducto.value.toLowerCase().trim();
    // Filtrar productos por nombre
    const productosFiltrados = productosActuales.filter(function(producto) {
        return producto.NOMBRE_PRODUCTO
            .toLowerCase()
            .includes(textoBusqueda);
    });
    // Limpiar la lista anterior
    listaProductos.innerHTML = "";
    // Comprobar si hay productos
    if (productosFiltrados.length === 0) {
        listaProductos.textContent =
            "No se encontraron productos.";
        return;
    }
    // Recorrer los productos encontrados
    productosFiltrados.forEach(function(producto) {
        // Obtener las existencias del producto
        const stockDisponible = Math.max(
            0,
            Number(producto.STOCK_DISPONIBLE) || 0
        );
        // Crear la tarjeta del producto
        const tarjeta = document.createElement("article");
        tarjeta.className = "tarjeta-producto-venta";
        // Crear el nombre
        const nombre = document.createElement("h3");
        nombre.textContent = producto.NOMBRE_PRODUCTO;
        // Crear la descripcion
        const descripcion = document.createElement("p");
        descripcion.textContent =
            producto.DESCRIPCION_PRODUCTO || "Sin descripcion.";
        // Crear el precio
        const precio = document.createElement("strong");
        precio.textContent =
            formatoMoneda.format(Number(producto.PRECIO_VENTA));
        // Crear el indicador de stock
        const existencia = document.createElement("p");
        existencia.className = "stock-producto";
        if (stockDisponible > 0) {
            existencia.textContent =
                "Disponibles: " + stockDisponible + " unidades";
            existencia.classList.add("stock-disponible");
        } else {
            existencia.textContent = "Producto agotado";
            existencia.classList.add("stock-agotado");
        }
        // Crear el boton para agregar
        const botonAgregar = document.createElement("button");
        botonAgregar.type = "button";
        botonAgregar.className = "boton-agregar-producto";
        // Si no hay existencias, desactivar el boton
        if (stockDisponible === 0) {
            botonAgregar.textContent = "Sin stock";
            botonAgregar.disabled = true;
        } else {
            botonAgregar.textContent = "Agregar al carrito";
            // Agregar el producto al carrito
            botonAgregar.addEventListener("click", function() {
                agregarAlCarrito(producto);
            });
        }
        // Agregar los elementos a la tarjeta
        tarjeta.appendChild(nombre);
        tarjeta.appendChild(descripcion);
        tarjeta.appendChild(precio);
        tarjeta.appendChild(existencia);
        tarjeta.appendChild(botonAgregar);
        // Mostrar la tarjeta
        listaProductos.appendChild(tarjeta);
    });
}

// ====== AGREGAR PRODUCTOS AL CARRITO =========

function agregarAlCarrito(producto) {
    // Obtener el identificador del producto
    const idProducto = producto.ID_PRODUCTO;
    // Usa el stock que el servidor consulto en SQL Server junto con los productos.
    const stockDisponible = Math.max(
        0,
        Number(producto.STOCK_DISPONIBLE) || 0
    );
    // Comprobar si existen unidades disponibles
    if (stockDisponible <= 0) {
        mensajeVenta.textContent =
            "Este producto no tiene existencias disponibles.";
        return;
    }
    // Comprobar si el producto ya esta en el carrito
    if (carrito.has(idProducto)) {
        // Obtener el producto existente
        const productoExistente = carrito.get(idProducto);
        // Comprobar si se puede aumentar la cantidad
        if (productoExistente.cantidad >= stockDisponible) {
            mensajeVenta.textContent =
                "No puedes agregar mas unidades. Stock disponible: "
                + stockDisponible;
            return;
        }
        // Actualizar el stock disponible
        productoExistente.stockDisponible = stockDisponible;
        // Aumentar la cantidad
        productoExistente.cantidad++;
    } else {
        // Agregar un nuevo producto al carrito
        carrito.set(idProducto, {
            id: producto.ID_PRODUCTO,
            nombre: producto.NOMBRE_PRODUCTO,
            precio: Number(producto.PRECIO_VENTA),
            cantidad: 1,
            // Guardar las existencias disponibles
            stockDisponible: stockDisponible
        });
    }
    // Actualizar el carrito
    mostrarCarrito();
    // Limpiar mensajes anteriores
    mensajeVenta.textContent = "";
}

// ======= MOSTRAR LOS PRODUCTOS DEL CARRITO ========

function mostrarCarrito() {
    // Limpiar el contenido anterior
    carritoVenta.innerHTML = "";
    // Comprobar si el carrito esta vacio
    if (carrito.size === 0) {
        carritoVenta.textContent =
            "Todavia no has agregado productos.";
        carritoVenta.className = "carrito-venta carrito-vacio";
        actualizarTotal();
        return;
    }
    carritoVenta.className = "carrito-venta";

    // Recorrer los productos del carrito
    carrito.forEach(function(producto) {
        // Crear el contenedor del producto
        const elemento = document.createElement("article");
        elemento.className = "elemento-carrito";
        // Crear la informacion del producto
        const informacion = document.createElement("div");
        informacion.className = "informacion-producto-carrito";
        // Nombre
        const nombre = document.createElement("strong");
        nombre.textContent = producto.nombre;
        // Precio
        const precio = document.createElement("p");
        precio.textContent =
            formatoMoneda.format(producto.precio) + " por unidad";
        informacion.appendChild(nombre);
        informacion.appendChild(precio);
        // Mostrar las existencias disponibles del producto
        const existencia = document.createElement("p");
        existencia.textContent =
            "Stock disponible: " + producto.stockDisponible;
        informacion.appendChild(existencia);
        // Crear los controles de cantidad
        const controles = document.createElement("div");
        controles.className = "controles-cantidad";
        // Boton disminuir
        const botonMenos = document.createElement("button");
        botonMenos.type = "button";
        botonMenos.textContent = "-";
        botonMenos.setAttribute("aria-label", "Disminuir cantidad");
        // Mostrar cantidad
        const cantidad = document.createElement("span");
        cantidad.textContent = producto.cantidad;
        // Boton aumentar
        const botonMas = document.createElement("button");
        botonMas.type = "button";
        botonMas.textContent = "+";
        botonMas.setAttribute("aria-label", "Aumentar cantidad");
        // Desactivar el boton si se alcanza el stock disponible
        botonMas.disabled =
        producto.cantidad >= producto.stockDisponible;
        // Disminuir cantidad
        botonMenos.addEventListener("click", function() {
            modificarCantidad(producto.id, -1);
        });
        // Aumentar cantidad
        botonMas.addEventListener("click", function() {
            modificarCantidad(producto.id, 1);
        });
        controles.appendChild(botonMenos);
        controles.appendChild(cantidad);
        controles.appendChild(botonMas);
        // Calcular el importe del producto
        const importe = document.createElement("strong");
        importe.textContent =
            formatoMoneda.format(producto.precio * producto.cantidad);
        // Boton para quitar el producto
        const botonQuitar = document.createElement("button");
        botonQuitar.type = "button";
        botonQuitar.textContent = "Quitar";
        botonQuitar.className = "boton-quitar-producto";
        botonQuitar.addEventListener("click", function() {
            carrito.delete(producto.id);
            mostrarCarrito();
        });
        // Agregar todo al elemento
        elemento.appendChild(informacion);
        elemento.appendChild(controles);
        elemento.appendChild(importe);
        elemento.appendChild(botonQuitar);
        // Mostrar en el carrito
        carritoVenta.appendChild(elemento);
    });
    // Actualizar el importe total
    actualizarTotal();
}

//======= MODIFICAR LA CANTIDAD DE UN PRODUCTO ==========

function modificarCantidad(idProducto, cambio) {
    // Obtener el producto del carrito
    const producto = carrito.get(idProducto);
    // Comprobar que exista
    if (!producto) {
        return;
    }
    // Calcular la nueva cantidad
    const nuevaCantidad = producto.cantidad + cambio;
    // Evitar cantidades menores a uno
    if (nuevaCantidad < 1) {
        return;
    }
    // Comprobar que no se supere el stock
    if (nuevaCantidad > producto.stockDisponible) {
        mensajeVenta.textContent =
            "No hay suficientes unidades disponibles.";
        return;
    }
    // Actualizar la cantidad
    producto.cantidad = nuevaCantidad;
    // Actualizar el carrito
    mostrarCarrito();
    // Limpiar mensajes anteriores
    mensajeVenta.textContent = "";
}

// ======== CALCULAR EL TOTAL DE LA VENTA ===========

function actualizarTotal() {
    let total = 0;
    let cantidadTotal = 0;
    // Recorrer todos los productos del carrito
    carrito.forEach(function(producto) {
        // Sumar los importes
        total += producto.precio * producto.cantidad;
        // Sumar las unidades
        cantidadTotal += producto.cantidad;
    });
    // Mostrar la cantidad total
    cantidadProductos.textContent = cantidadTotal;
    // Mostrar el importe total
    totalVenta.textContent = formatoMoneda.format(total);
}

//======= CREAR BOTON DEL COMPROBANTE ==========

function crearBotonComprobante(idVenta) {
    // Eliminar el boton anterior si existe
    if (botonComprobanteAnterior) {
        botonComprobanteAnterior.remove();
    }
    const boton = document.createElement("button");
    boton.type = "button";
    boton.className = "boton-finalizar-venta";
    boton.textContent = "Ver / imprimir comprobante";
    boton.addEventListener("click", function() {
        abrirComprobante(idVenta);
    });
    mensajeVenta.insertAdjacentElement("afterend", boton);
    botonComprobanteAnterior = boton;
}

//========= ABRIR COMPROBANTE DIGITAL =============

async function abrirComprobante(idVenta) {
    // Abrir la ventana inmediatamente para evitar
    // que el navegador bloquee la ventana emergente.
    const ventana = window.open(
        "",
        "_blank",
        "width=420,height=700"
    );
    if (!ventana) {
        mensajeVenta.textContent =
            "Permite las ventanas emergentes para imprimir.";
        return;
    }
    ventana.document.write(
        "<h2>Generando comprobante...</h2>"
    );
    try {
        // Consultar los datos de la venta en SQL Server
        const respuesta = await fetch(
            "/api/ventas/" +
            encodeURIComponent(idVenta) +
            "/detalle"
        );
        const resultado = await respuesta.json();
        if (!respuesta.ok || !resultado.correcto) {
            throw new Error(
                resultado.mensaje ||
                "No se pudo obtener el comprobante."
            );
        }
        // Obtener los datos recibidos
        const venta = resultado.venta;
        const productos = resultado.productos;
        const pagos = resultado.pagos;
        // Evitar que los datos se interpreten como HTML
        function escaparHTML(valor) {
            return String(valor ?? "").replace(
                /[&<>"']/g,
                caracter => ({
                    "&": "&amp;",
                    "<": "&lt;",
                    ">": "&gt;",
                    '"': "&quot;",
                    "'": "&#039;"
                })[caracter]
            );
        }
        // Formatear la fecha
        const fecha = new Date(venta.FECHA_VENTA);
        const fechaTexto = fecha.toLocaleString("es-PE", {
            dateStyle: "short",
            timeStyle: "short"
        });
        // Crear las filas de productos
        const filasProductos = productos.map(producto => `
            <tr>
                <td>${escaparHTML(producto.NOMBRE_PRODUCTO)}</td>
                <td>${producto.CANTIDAD_VENTA}</td>
                <td>${formatoMoneda.format(
                    Number(producto.SUBTOTAL)
                )}</td>
            </tr>
        `).join("");
        // Mostrar los métodos de pago
        const detallePagos = pagos.map(pago => `
            <p>
                ${escaparHTML(pago.METODO_PAGO)}:
                ${formatoMoneda.format(Number(pago.MONTO_PAGO))}
            </p>
        `).join("");
        // Crear el contenido de la boleta
        ventana.document.open();
        ventana.document.write(`
            <!DOCTYPE html>
            <html lang="es">
            <head>
                <meta charset="UTF-8">
                <title>Comprobante de venta</title>
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        width: 72mm;
                        margin: 15px auto;
                        color: #222;
                        font-size: 12px;
                    }
                    h1, h2, .centrado {
                        text-align: center;
                    }
                    h1 {
                        font-size: 20px;
                    }
                    h2 {
                        font-size: 14px;
                    }
                    .separador {
                        border-top: 1px dashed #555;
                        margin: 12px 0;
                    }
                    table {
                        width: 100%;
                        border-collapse: collapse;
                        font-size: 11px;
                    }
                    th, td {
                        text-align: left;
                        padding: 5px 2px;
                    }
                    .total {
                        font-size: 17px;
                        font-weight: bold;
                        text-align: right;
                    }
                    .no-imprimir {
                        width: 100%;
                        padding: 12px;
                        margin-top: 20px;
                        background: #245c45;
                        color: white;
                        border: none;
                        border-radius: 6px;
                        cursor: pointer;
                    }
                    @media print {
                        @page {
                            margin: 4mm;
                        }
                        body {
                            margin: 0 auto;
                        }
                        .no-imprimir {
                            display: none;
                        }
                    }
                </style>
            </head>
            <body>
                <h1>MI BARRIO MARKET</h1>
                <p class="centrado">
                    COMPROBANTE DE VENTA
                </p>
                <h2>
                    ${escaparHTML(venta.TIPO_COMPROBANTE)}
                </h2>
                <div class="separador"></div>
                <p><strong>Número:</strong> ${venta.ID_VENTA}</p>
                <p><strong>Fecha:</strong> ${escaparHTML(fechaTexto)}</p>
                <p><strong>Caja:</strong> ${escaparHTML(venta.NUMERO_CAJA)}</p>
                <div class="separador"></div>
                <h2>DATOS DEL CLIENTE</h2>
                <p><strong>DNI:</strong> ${escaparHTML(venta.DNI)}</p>
                <p>
                    <strong>Cliente:</strong>
                    ${escaparHTML(venta.NOMBRE_CLIENTE)}
                    ${escaparHTML(venta.APELLIDO_CLIENTE)}
                </p>
                <div class="separador"></div>
                <h2>DETALLE DE PRODUCTOS</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Producto</th>
                            <th>Cant.</th>
                            <th>Importe</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${filasProductos}
                    </tbody>
                </table>
                <div class="separador"></div>
                <h2>DATOS DE PAGO</h2>
                ${detallePagos}
                <div class="separador"></div>
                <p class="total">
                    TOTAL:
                    ${formatoMoneda.format(
                        Number(venta.TOTAL_VENTA)
                    )}
                </p>
                <div class="separador"></div>
                <p class="centrado">
                    ¡Gracias por su compra!
                </p>
                <p class="centrado">
                    Mi Barrio Market
                </p>
                <p class="centrado">
                    Comprobante interno de demostración académica.
                </p>
                <button
                    class="no-imprimir"
                    id="btn-imprimir"
                    type="button"
                >
                    Imprimir / Guardar PDF
                </button>
            </body>
            </html>
        `);
        ventana.document.close();
        // Activar el botón de impresión
        ventana.document
            .getElementById("btn-imprimir")
            .addEventListener("click", function() {
                ventana.print();
            });
    } catch (error) {
        console.error(
            "Error al generar comprobante:",
            error
        );
        ventana.document.body.textContent =
            error.message ||
            "No se pudo generar el comprobante.";
    }
}

// ==========  DETECTAR CAMBIO DE CATEGORIA ============

selectorCategoria.addEventListener("change", function() {
    const opcionSeleccionada =
        selectorCategoria.selectedOptions[0];
    // Si no hay categoria seleccionada
    if (!selectorCategoria.value) {
        descripcionCategoria.textContent =
            "Selecciona una categoria.";
        productosActuales = [];
        listaProductos.textContent =
            "Selecciona una categoria para ver los productos.";
        return;
    }
    // Mostrar descripcion de la categoria
    descripcionCategoria.textContent =
        opcionSeleccionada.dataset.descripcion;
    // Limpiar la busqueda
    buscarProducto.value = "";
    // Consultar los productos
    cargarProductos(selectorCategoria.value);
});

// ======= BUSCAR PRODUCTOS POR NOMBRE =========

buscarProducto.addEventListener("input", function() {
    mostrarProductos();
});

// Envia la venta a la API para validarla y registrarla en SQL Server.

async function validarVenta() {

    // Obtener los datos del cliente
    const dni = document.getElementById("dni-cliente").value.trim();
    const nombre = document.getElementById("nombre-cliente").value.trim();
    const apellido = document.getElementById("apellido-cliente").value.trim();
    // Obtener el comprobante y metodo de pago
    const comprobante = document.getElementById("comprobante-venta").value;
    const metodoPago = document.getElementById("metodo-pago").value;
    // Obtener el boton de registro
    const boton = document.getElementById("btn-validar-venta");

    // ==========================================
    // 1. VALIDAR LOS DATOS ANTES DE ENVIAR
    // ==========================================

    // Comprobar que el carrito tenga productos
    if (carrito.size === 0) {
        mensajeVenta.textContent =
            "Primero debes agregar productos al carrito.";
        return;
    }
    // Comprobar el DNI
    if (!/^\d{8}$/.test(dni)) {
        mensajeVenta.textContent =
            "El DNI debe contener exactamente 8 numeros.";
        return;
    }
    // Comprobar nombres y apellidos
    if (!nombre || !apellido) {
        mensajeVenta.textContent =
            "Completa los nombres y apellidos del cliente.";
        return;
    }
    // Comprobar el comprobante
    if (!comprobante) {
        mensajeVenta.textContent =
            "Selecciona un tipo de comprobante.";
        return;
    }
    // Comprobar el metodo de pago
    if (!metodoPago) {
        mensajeVenta.textContent =
            "Selecciona una forma de pago.";
        return;
    }

    // ==========================================
    // 2. PREPARAR LOS PRODUCTOS DEL CARRITO
    // ==========================================

    // Envia IDs y cantidades; el servidor valida el precio y el stock actuales en SQL Server.
    const productosVenta = Array.from(carrito.values()).map(
        function(producto) {
            return {
                idProducto: producto.id,
                cantidad: producto.cantidad
            };
        }
    );

    // ==========================================
    // 3. ENVIAR LOS DATOS AL SERVIDOR
    // ==========================================

    try {
        // Evitar que el usuario registre dos veces
        // la misma venta mientras se procesa
        boton.disabled = true;
        boton.textContent = "Registrando venta...";
        mensajeVenta.textContent =
            "Enviando los datos al servidor...";
        // Envia los datos a la ruta del servidor que registra la venta en una transaccion SQL.
        const respuesta = await fetch("/api/ventas/registrar", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                dni: dni,
                nombre: nombre,
                apellido: apellido,
                idComprobante: Number(comprobante),
                idPago: Number(metodoPago),
                productos: productosVenta
            })
        });
        // Recibir la respuesta del servidor
        const resultado = await respuesta.json().catch(
            function() {
                return {};
            }
        );
        // Comprobar si el servidor registro correctamente
        if (!respuesta.ok || !resultado.correcto) {
            throw new Error(
                resultado.mensaje ||
                "No se pudo registrar la venta."
            );
        }

        // ==========================================
        // 4. MOSTRAR LA CONFIRMACION DE LA VENTA
        // ==========================================

        const idVenta = resultado.datos.idVenta;
        const totalRegistrado = Number(
            resultado.datos.total
        );
        mensajeVenta.textContent =
            "¡Venta registrada correctamente! " +
            "Numero de venta: " + idVenta +
            ". Total: " +
            formatoMoneda.format(totalRegistrado);

        // Mostrar boton para consultar e imprimir la boleta
        crearBotonComprobante(idVenta);
        
        // ==========================================
        // 5. LIMPIAR EL CARRITO DESPUES DEL REGISTRO
        // ==========================================

        carrito.clear();
        // Actualizar la pantalla del carrito
        mostrarCarrito();
        // Limpiar los datos del cliente
        document.getElementById("dni-cliente").value = "";
        document.getElementById("nombre-cliente").value = "";
        document.getElementById("apellido-cliente").value = "";
        // Reiniciar los selectores de pago
        document.getElementById("comprobante-venta").value = "";
        document.getElementById("metodo-pago").value = "";

        // ==========================================
        // 6. ACTUALIZAR EL STOCK EN LA PANTALLA
        // ==========================================

        // Volver a consultar los productos de la categoria actual
        if (selectorCategoria.value) {
            await cargarProductos(selectorCategoria.value);
        }
    } catch (error) {
        // Mostrar el error en la terminal del navegador
        console.error(
            "Error al registrar la venta:",
            error
        );
        // Informar al usuario
        mensajeVenta.textContent = error.message ||
            "Ocurrio un error al registrar la venta.";
    } finally {
        // Reactivar el boton despues de terminar
        boton.disabled = false;
        boton.textContent = "Validar venta";
    }
}

// ======== DETECTAR CAMBIO DE COMPROBANTE ========

selectorComprobante.addEventListener("change", function() {
    // Cambiar los campos del cliente
    mostrarCamposCliente();
    // Limpiar mensajes anteriores
    mensajeVenta.textContent = "";
});

// ========== BOTON DE VALIDACION ==============
document.getElementById("btn-validar-venta")
    .addEventListener("click", validarVenta);

//=========INICIAR LA PANTALLA ==================
cargarCategorias();
mostrarCarrito();

// Mostrar los campos iniciales del cliente
mostrarCamposCliente();