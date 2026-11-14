// Obtener los elementos de la pagina
const reponedorCompra = document.getElementById("reponedor-compra");
const proveedorCompra = document.getElementById("proveedor-compra");
const categoriaCompra = document.getElementById("categoria-compra");
const productoCompra = document.getElementById("producto-compra");
const cantidadCompra = document.getElementById("cantidad-compra");
const costoCompra = document.getElementById("costo-compra");
const carritoCompra = document.getElementById("carrito-compra");
const cantidadUnidades = document.getElementById("cantidad-unidades-compra");
const totalCompra = document.getElementById("total-compra");
const botonAgregar = document.getElementById("btn-agregar-producto-compra");
const botonRegistrar = document.getElementById("btn-registrar-compra");
const mensajeCompra = document.getElementById("mensaje-compra");
const mensajeRegistro = document.getElementById("mensaje-registro-compra");
// Variables del modulo
let productosActuales = [];
const carrito = new Map();
let registroEnProceso = false;
// Formato de moneda peruana
const formatoMoneda = new Intl.NumberFormat("es-PE", {
    style: "currency",
    currency: "PEN"
});

// Consulta la API del servidor, que obtiene los datos desde SQL Server.

async function consultarAPI(url) {
    // Centraliza la solicitud y el manejo de errores de las lecturas de datos.
    const respuesta = await fetch(url);
    const resultado = await respuesta.json();
    if (!respuesta.ok || !resultado.correcto) {
        throw new Error(
            resultado.mensaje || "Error al consultar los datos."
        );
    }
    return resultado;
}

//========== CARGAR REPONEDORES ================

async function cargarReponedores() {
    try {
        // El servidor consulta los reponedores activos en la base de datos.
        const resultado = await consultarAPI(
            "/api/compras/reponedores"
        );
        reponedorCompra.replaceChildren();
        const opcionInicial = document.createElement("option");
        opcionInicial.value = "";
        opcionInicial.textContent = "Seleccionar reponedor";
        reponedorCompra.appendChild(opcionInicial);
        resultado.reponedores.forEach(function(reponedor) {
            const opcion = document.createElement("option");
            opcion.value = reponedor.ID_EMPLEADO;
            opcion.textContent =
                reponedor.NOMBRE_COMPLETO ||
                reponedor.NOMBRE_EMPLEADO + " " +
                reponedor.APELLIDO_EMPLEADO;
            reponedorCompra.appendChild(opcion);
        });
    } catch (error) {
        console.error("Error al cargar reponedores:", error);
        reponedorCompra.innerHTML =
            '<option value="">Error al cargar reponedores</option>';
    }
}

//======== CARGAR PROVEEDORES ============

async function cargarProveedores() {
    try {
        // Obtiene de SQL Server los proveedores disponibles para la compra.
        const resultado = await consultarAPI(
            "/api/compras/proveedores"
        );
        proveedorCompra.replaceChildren();
        const opcionInicial = document.createElement("option");
        opcionInicial.value = "";
        opcionInicial.textContent = "Seleccionar proveedor";
        proveedorCompra.appendChild(opcionInicial);
        resultado.proveedores.forEach(function(proveedor) {
            const opcion = document.createElement("option");
            opcion.value = String(proveedor.RUC).trim();
            opcion.textContent = proveedor.NOMBRE_PROVEEDOR;
            proveedorCompra.appendChild(opcion);
        });
    } catch (error) {
        console.error("Error al cargar proveedores:", error);
        proveedorCompra.innerHTML =
            '<option value="">Error al cargar proveedores</option>';
    }
}

//======== CARGAR CATEGORIAS SEGUN PROVEEDOR ==============

async function cargarCategorias(ruc) {
    try {
        // Deshabilitar el selector mientras se consultan las categorías.
        categoriaCompra.disabled = true;
        // Consultar las categorías que corresponden al proveedor seleccionado.
        const resultado = await consultarAPI(
            "/api/compras/categorias?ruc=" +
            encodeURIComponent(ruc)
        );
        // Limpiar las categorías anteriores.
        categoriaCompra.replaceChildren();
        // Crear la opción inicial del selector.
        const opcionInicial = document.createElement("option");
        opcionInicial.value = "";
        opcionInicial.textContent = "Seleccionar categoría";
        categoriaCompra.appendChild(opcionInicial);
        // Recorrer las categorías devueltas por SQL Server.
        resultado.categorias.forEach(function(categoria) {
            const opcion = document.createElement("option");
            // Asignar el ID de la categoría como valor.
            opcion.value = categoria.ID_CATEGORIA;
            // Mostrar el nombre de la categoría.
            opcion.textContent = categoria.NOMBRE_CATEGORIA;
            categoriaCompra.appendChild(opcion);
        });
        // Habilitar el selector si existen categorías.
        categoriaCompra.disabled =
            resultado.categorias.length === 0;
        if (resultado.categorias.length === 0) {
            categoriaCompra.innerHTML =
                '<option value="">Este proveedor no tiene categorías</option>';
        }
    } catch (error) {
        console.error("Error al cargar categorías:", error);
        categoriaCompra.innerHTML =
            '<option value="">Error al cargar categorías</option>';
        categoriaCompra.disabled = true;
        mensajeCompra.textContent =
            "No se pudieron cargar las categorías del proveedor.";
    }
}

//======CARGAR PRODUCTOS SEGUN LA CATEGORIA ===========

async function cargarProductos(idCategoria) {
    try {
        productoCompra.disabled = true;
                // Limpiar el costo del producto seleccionado anteriormente.
        costoCompra.value = "";
        productoCompra.innerHTML =
            '<option value="">Cargando productos...</option>';
        productosActuales = [];
        // Consultar los productos disponibles para compras
        const resultado = await consultarAPI(
            "/api/compras/productos"
        );
        // Filtrar los productos de la categoría seleccionada
        productosActuales = resultado.productos.filter(
            function(producto) {
                return Number(producto.ID_CATEGORIA) ===
                    Number(idCategoria);
            }
        );
        // Limpiar el selector
        productoCompra.replaceChildren();
        const opcionInicial = document.createElement("option");
        opcionInicial.value = "";
        opcionInicial.textContent = "Seleccionar producto";
        productoCompra.appendChild(opcionInicial);
        // Mostrar los productos encontrados
        productosActuales.forEach(function(producto) {
            const opcion = document.createElement("option");
            opcion.value = producto.ID_PRODUCTO;
            opcion.textContent =
                producto.NOMBRE_PRODUCTO +
                " (Stock: " +
                Number(producto.STOCK_DISPONIBLE) +
                ")";
            productoCompra.appendChild(opcion);
        });
        productoCompra.disabled =
            productosActuales.length === 0;
        if (productosActuales.length === 0) {
            productoCompra.innerHTML =
                '<option value="">No hay productos en esta categoría</option>';
        }
    } catch (error) {
        console.error("Error al cargar productos:", error);
        productoCompra.innerHTML =
            '<option value="">Error al cargar productos</option>';
        mensajeCompra.textContent =
            "No se pudieron cargar los productos.";
    }
}

//====== ACTUALIZAR COSTO AUTOMATICAMENTE ======

function actualizarCostoCompra() {
    // Obtener el ID del producto seleccionado.
    const idProducto = Number(productoCompra.value);
    // Buscar el producto seleccionado en la lista cargada desde SQL Server.
    const productoSeleccionado = productosActuales.find(
        function(producto) {
            return Number(producto.ID_PRODUCTO) === idProducto;
        }
    );
    // Si no hay producto seleccionado, limpiar el campo.
    if (!productoSeleccionado) {
        costoCompra.value = "";
        return;
    }
    // Obtener el último costo registrado en DETALLE_COMPRA.
    const ultimoCosto = productoSeleccionado.ULTIMO_COSTO_COMPRA;
    // omprobar si el producto tiene compras anteriores.
    if (
        ultimoCosto === null ||
        ultimoCosto === undefined
    ) {
        costoCompra.value = "";
        mensajeCompra.textContent =
            "Este producto no tiene compras anteriores. " +
            "Ingresa su primer costo.";
        return;
    }
    // Colocar automáticamente el costo en el formulario.
    costoCompra.value = Number(ultimoCosto).toFixed(2);
    mensajeCompra.textContent =
        "Costo de compra cargado automáticamente.";
}

//====== AGREGAR PRODUCTOS AL CARRITO ===========

function agregarProductoCompra() {
    const idProducto = Number(productoCompra.value);
    const cantidad = Number(cantidadCompra.value);
    const costo = Number(costoCompra.value);
    const producto = productosActuales.find(function(item) {
        return Number(item.ID_PRODUCTO) === idProducto;
    });
    if (!producto) {
        mensajeCompra.textContent =
            "Selecciona un producto.";
        return;
    }
    if (!Number.isSafeInteger(cantidad) || cantidad <= 0) {
        mensajeCompra.textContent =
            "Ingresa una cantidad válida.";
        return;
    }
    if (!Number.isFinite(costo) || costo <= 0) {
        mensajeCompra.textContent =
            "Ingresa un costo unitario mayor que cero.";
        return;
    }
    const costoCentavos = Math.round(costo * 100);
    if (costoCentavos <= 0 || costoCentavos / 100 !== costo) {
        mensajeCompra.textContent =
            "El costo debe tener como máximo dos decimales.";
        return;
    }
    // El procedimiento almacenado no permite
    // repetir el mismo producto en una compra.
    if (carrito.has(idProducto)) {
        mensajeCompra.textContent =
            "Este producto ya está agregado. " +
            "Puedes quitarlo y volver a agregarlo.";
        return;
    }
    carrito.set(idProducto, {
        id: idProducto,
        nombre: producto.NOMBRE_PRODUCTO,
        cantidad: cantidad,
        costoCentavos: costoCentavos
    });
    mostrarCarrito();
    // Limpiar los campos
    cantidadCompra.value = 1;
    costoCompra.value = "";
    productoCompra.value = "";
    mensajeCompra.textContent =
        "Producto agregado correctamente.";
}

//========== MOSTRAR CARRITO ===============

function mostrarCarrito() {
    carritoCompra.replaceChildren();
    if (carrito.size === 0) {
        const mensaje = document.createElement("p");
        mensaje.className = "carrito-vacio";
        mensaje.textContent =
            "Todavía no hay productos agregados.";
        carritoCompra.appendChild(mensaje);
        actualizarTotalCompra();
        return;
    }
    carrito.forEach(function(producto) {
        const elemento = document.createElement("article");
        elemento.className = "elemento-carrito";
        const informacion = document.createElement("div");
        informacion.className = "informacion-producto-carrito";
        const nombre = document.createElement("strong");
        nombre.textContent = producto.nombre;
        const costo = document.createElement("p");
        costo.textContent =
            formatoMoneda.format(producto.costoCentavos / 100) +
            " por unidad";
        informacion.appendChild(nombre);
        informacion.appendChild(costo);
        const cantidad = document.createElement("strong");
        cantidad.textContent = "x " + producto.cantidad;
        const subtotal = document.createElement("strong");
        subtotal.textContent = formatoMoneda.format(
            producto.costoCentavos * producto.cantidad / 100
        );
        const botonQuitar = document.createElement("button");
        botonQuitar.type = "button";
        botonQuitar.className = "boton-quitar-producto";
        botonQuitar.textContent = "Quitar";
        botonQuitar.addEventListener("click", function() {
            carrito.delete(producto.id);
            mostrarCarrito();
            mensajeCompra.textContent =
                "Producto eliminado del detalle.";
        });
        elemento.appendChild(informacion);
        elemento.appendChild(cantidad);
        elemento.appendChild(subtotal);
        elemento.appendChild(botonQuitar);
        carritoCompra.appendChild(elemento);
    });
    actualizarTotalCompra();
}

//====== CALCULAR TOTAL DE LA COMPRA ============

function actualizarTotalCompra() {
    let totalCentavos = 0;
    let unidades = 0;
    carrito.forEach(function(producto) {
        totalCentavos +=
            producto.costoCentavos * producto.cantidad;
        unidades += producto.cantidad;
    });
    cantidadUnidades.textContent = unidades;
    totalCompra.textContent = formatoMoneda.format(
        totalCentavos / 100
    );
    actualizarEstadoBotonRegistro();
}

async function registrarCompra() {
    if (registroEnProceso) return;
    if (!reponedorCompra.value || !proveedorCompra.value) {
        mensajeRegistro.textContent =
            "Selecciona un reponedor y un proveedor.";
        return;
    }
    if (carrito.size === 0) {
        mensajeRegistro.textContent =
            "Agrega productos a la compra.";
        return;
    }
    const productos = Array.from(carrito.values()).map(producto => ({
        idProducto: producto.id,
        cantidad: producto.cantidad,
        costo: producto.costoCentavos / 100
    }));
    const totalCentavos = productos.reduce(
        (total, producto) =>
            total + Math.round(producto.costo * 100) * producto.cantidad,
        0
    );
    if (!window.confirm(
        "¿Deseas registrar esta compra por " +
        formatoMoneda.format(totalCentavos / 100) + "?"
    )) {
        return;
    }
    registroEnProceso = true;
    actualizarEstadoBotonRegistro();
    mensajeRegistro.textContent = "Registrando compra...";
    try {
        // Envia la compra a la API para guardarla en SQL Server con sus productos.
        const respuesta = await fetch("/api/compras/registrar", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                idEmpleado: Number(reponedorCompra.value),
                ruc: proveedorCompra.value,
                productos: productos
            })
        });
        const resultado = await respuesta.json();
        if (!respuesta.ok || !resultado.correcto) {
            throw new Error(
                resultado.mensaje || "No se pudo registrar la compra."
            );
        }
        // Limpiar carrito después del registro exitoso
        carrito.clear();
        mostrarCarrito();
        cantidadCompra.value = 1;
        costoCompra.value = "";
        productoCompra.value = "";
        mensajeRegistro.textContent =
            "¡Compra registrada correctamente! Número de compra: " +
            resultado.idCompra;
        // Actualizar stock de la categoría seleccionada
        if (categoriaCompra.value) {
            await cargarProductos(categoriaCompra.value);
        }
    } catch (error) {
        console.error("Error al registrar compra:", error);
        mensajeRegistro.textContent =
            error.message || "Ocurrió un error al registrar la compra.";
    } finally {
        registroEnProceso = false;
        actualizarEstadoBotonRegistro();
    }
}

reponedorCompra.addEventListener(
    "change",
    actualizarEstadoBotonRegistro
);

//====== DETECTAR CAMBIO DE PROVEEDOR ======

proveedorCompra.addEventListener("change", async function() {
    // Actualizar el estado del botón de registro.
    actualizarEstadoBotonRegistro();
    // Limpiar los productos y costos anteriores.
    productosActuales = [];
    costoCompra.value = "";
    // Reiniciar el selector de productos.
    productoCompra.disabled = true;
    productoCompra.innerHTML =
        '<option value="">Selecciona una categoría primero</option>';
    // Deshabilitar el selector de categorías mientras se actualiza.
    categoriaCompra.disabled = true;
    // Comprobar si se seleccionó un proveedor.
    if (!proveedorCompra.value) {
        categoriaCompra.innerHTML =
            '<option value="">Selecciona un proveedor primero</option>';
        return;
    }
    // Cargar únicamente las categorías del proveedor seleccionado.
    await cargarCategorias(proveedorCompra.value);
});

botonRegistrar.addEventListener(
    "click",
    registrarCompra
);

//====== ACTUALIZAR ESTADO DEL BOTON REGISTRAR ======

function actualizarEstadoBotonRegistro() {
    botonRegistrar.disabled =
        registroEnProceso ||
        carrito.size === 0 ||
        !reponedorCompra.value ||
        !proveedorCompra.value;
}

//======= DETECTAR CAMBIO DE CATEGORIA =========

categoriaCompra.addEventListener("change", function() {
    if (!categoriaCompra.value) {
        productosActuales = [];
        // Limpiar el costo cuando no hay categoría seleccionada.
        costoCompra.value = "";
        productoCompra.disabled = true;
        productoCompra.innerHTML =
            '<option value="">Selecciona una categoría primero</option>';
        return;
    }
    // Cargar los productos de la categoría seleccionada.
    cargarProductos(categoriaCompra.value);
});

//====== DETECTAR CAMBIO DE PRODUCTO ======

// Cuando se selecciona un producto, cargar su último costo.
productoCompra.addEventListener("change", function() {
    actualizarCostoCompra();
});

//====== DETECTAR CLIC EN AGREGAR PRODUCTO ========

botonAgregar.addEventListener("click", function() {
    agregarProductoCompra();
});

//========= INICIAR MODULO DE COMPRAS =============

async function iniciarCompras() {
    // Al iniciar, todavía no se ha seleccionado un proveedor.
    categoriaCompra.disabled = true;
    categoriaCompra.innerHTML =
        '<option value="">Selecciona un proveedor primero</option>';
    productoCompra.disabled = true;
    productoCompra.innerHTML =
        '<option value="">Selecciona una categoría primero</option>';
    // Cargar los datos iniciales del formulario.
    await Promise.all([
        cargarReponedores(),
        cargarProveedores()
    ]);
    // Mostrar el carrito vacío.
    mostrarCarrito();
    mensajeRegistro.textContent = "";
    actualizarEstadoBotonRegistro();
}

iniciarCompras();