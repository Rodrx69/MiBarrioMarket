const tablaVentas = document.getElementById("tabla-ventas");
const buscarVenta = document.getElementById("buscar-venta");
const contadorVentas = document.getElementById("contador-ventas");
const mensajeHistorial = document.getElementById("mensaje-historial");
const botonActualizar = document.getElementById("btn-actualizar");

// Elementos de la ventana emergente
const modalDetalleVenta =
    document.getElementById("modal-detalle-venta");
const tituloModalDetalle =
    document.getElementById("titulo-modal-detalle");
const contenidoDetalleVenta =
    document.getElementById("contenido-detalle-venta");
const botonCerrarDetalle =
    document.getElementById("btn-cerrar-detalle");
// Guardar las ventas recibidas del servidor
let ventasRegistradas = [];

//========= FORMATEAR FECHA =========

function formatearFecha(fecha) {
    if (!fecha) return "—";
    // SQL Server devuelve fechas sin zona horaria.
    // Evitamos que JavaScript reste las 5 horas de Perú.
    const fechaTexto = String(fecha).replace(/Z$/, "");
    const fechaConvertida = new Date(fechaTexto);
    if (Number.isNaN(fechaConvertida.getTime())) {
        return String(fecha);
    }
    return fechaConvertida.toLocaleString("es-PE", {
        dateStyle: "short",
        timeStyle: "short"
    });
}

//======== FORMATEAR MONEDA ==============

function formatearMoneda(valor) {
    return new Intl.NumberFormat("es-PE", {
        style: "currency",
        currency: "PEN"
    }).format(Number(valor) || 0);
}

//======== CREAR ELEMENTOS HTML DE FORMA SEGURA ============

function crearElemento(etiqueta, clase, texto) {
    const elemento = document.createElement(etiqueta);
    if (clase) {
        elemento.className = clase;
    }
    if (texto !== undefined && texto !== null) {
        elemento.textContent = String(texto);
    }
    return elemento;
}

// Solicita al servidor el historial que consulta desde SQL Server.

async function cargarVentas() {
    botonActualizar.disabled = true;
    mensajeHistorial.textContent = "Consultando ventas...";
    tablaVentas.innerHTML = `
        <tr>
            <td colspan="10">Cargando ventas...</td>
        </tr>
    `;
    try {
        // La API devuelve las ventas recientes leidas desde la base de datos.
        const respuesta = await fetch("/api/ventas/historial");
        if (!respuesta.ok) {
            throw new Error("Error al consultar el servidor.");
        }
        const datos = await respuesta.json();
        if (!datos.correcto) {
            throw new Error(datos.mensaje);
        }
        // Guardar las ventas recibidas
        ventasRegistradas = datos.ventas || [];
        // Mostrar los resultados
        mostrarVentas();
        mensajeHistorial.textContent =
            "Historial cargado correctamente.";
    } catch (error) {
        console.error("Error al cargar ventas:", error);
        tablaVentas.innerHTML = `
            <tr>
                <td colspan="10">
                    No se pudo cargar el historial.
                </td>
            </tr>
        `;
        contadorVentas.textContent =
            "Error al consultar ventas.";
        mensajeHistorial.textContent = error.message;
    } finally {
        botonActualizar.disabled = false;
    }
}

//======== MOSTRAR LAS VENTAS EN LA TABLA =============

function mostrarVentas() {
    const termino = buscarVenta.value
        .trim()
        .toLowerCase();
    // Filtrar las ventas
    const ventasFiltradas = ventasRegistradas.filter(venta => {
        const textoVenta = [
            venta.ID_VENTA,
            venta.FECHA_VENTA,
            formatearFecha(venta.FECHA_VENTA),
            venta.DNI,
            venta.NOMBRE_CLIENTE,
            venta.APELLIDO_CLIENTE,
            venta.NUMERO_CAJA,
            venta.TIPO_COMPROBANTE,
            venta.METODOS_PAGO
        ].join(" ").toLowerCase();
        return textoVenta.includes(termino);
    });
    // Actualizar contador
    contadorVentas.textContent =
        `Mostrando ${ventasFiltradas.length} de ${ventasRegistradas.length} ventas.`;
    // Limpiar tabla
    tablaVentas.replaceChildren();
    // Comprobar si existen resultados
    if (ventasFiltradas.length === 0) {
        tablaVentas.innerHTML = `
            <tr>
                <td colspan="10">
                    No se encontraron ventas.
                </td>
            </tr>
        `;
        return;
    }
    // Crear una fila por cada venta
    ventasFiltradas.forEach(venta => {
        const fila = document.createElement("tr");
        const valores = [
            venta.ID_VENTA,
            formatearFecha(venta.FECHA_VENTA),
            `${venta.NOMBRE_CLIENTE || ""} ${venta.APELLIDO_CLIENTE || ""}`,
            venta.DNI || "—",
            venta.NUMERO_CAJA ?? "—",
            venta.TIPO_COMPROBANTE || "—",
            venta.CANTIDAD_PRODUCTOS ?? 0,
            formatearMoneda(venta.TOTAL_VENTA),
            venta.METODOS_PAGO || "—"
        ];
        // Crear las celdas de información
        valores.forEach(valor => {
            const celda = document.createElement("td");
            celda.textContent = valor;
            fila.appendChild(celda);
        });
        // Crear la celda de acciones
        const celdaAcciones = document.createElement("td");
        const botonDetalle = document.createElement("button");
        botonDetalle.type = "button";
        botonDetalle.className = "boton-detalle-venta";
        botonDetalle.textContent = "Ver detalle";
        // Consultar el detalle de la venta seleccionada
        botonDetalle.addEventListener("click", () => {
            mostrarDetalleVenta(venta.ID_VENTA, botonDetalle);
        });
        celdaAcciones.appendChild(botonDetalle);
        fila.appendChild(celdaAcciones);
        tablaVentas.appendChild(fila);
    });
}

//======== CREAR UNA SECCION DEL DETALLE =============

function crearSeccionDetalle(titulo) {
    const seccion = crearElemento(
        "section",
        "seccion-modal-detalle"
    );
    const encabezado = crearElemento(
        "h3",
        "",
        titulo
    );
    seccion.appendChild(encabezado);
    return seccion;
}

//========= AGREGAR UN DATO GENERAL DE LA VENTA ============

function agregarDato(contenedor, etiqueta, valor) {
    const elemento = crearElemento(
        "div",
        "dato-modal"
    );
    const nombre = crearElemento(
        "span",
        "",
        etiqueta
    );
    const contenido = crearElemento(
        "strong",
        "",
        valor ?? "—"
    );
    elemento.appendChild(nombre);
    elemento.appendChild(contenido);
    contenedor.appendChild(elemento);
}

//======== CREAR TABLAS PARA PRODUCTOS Y PAGOS ===========

function crearTablaDetalle(encabezados, filas) {
    const tabla = crearElemento(
        "table",
        "tabla-modal-detalle"
    );
    const thead = document.createElement("thead");
    const filaEncabezado = document.createElement("tr");
    encabezados.forEach(texto => {
        const th = crearElemento("th", "", texto);
        filaEncabezado.appendChild(th);
    });
    thead.appendChild(filaEncabezado);
    tabla.appendChild(thead);
    const tbody = document.createElement("tbody");
    filas.forEach(valores => {
        const fila = document.createElement("tr");
        valores.forEach(valor => {
            const celda = document.createElement("td");
            celda.textContent = valor ?? "—";
            fila.appendChild(celda);
        });
        tbody.appendChild(fila);
    });
    tabla.appendChild(tbody);
    return tabla;
}

//========== MOSTRAR EL DETALLE DE UNA VENTA ==============

function mostrarDetalleEnModal(datos) {
    const venta = datos.venta;
    const productos = datos.productos || [];
    const pagos = datos.pagos || [];

    // Limpiar contenido anterior
    contenidoDetalleVenta.replaceChildren();

    // Actualizar titulo
    tituloModalDetalle.textContent =
        `Detalle de venta N.º ${venta.ID_VENTA}`;

    // ==========================================
    // 1. DATOS GENERALES
    // ==========================================

    const seccionDatos = crearSeccionDetalle(
        "Datos de la venta"
    );
    const cliente = [
        venta.NOMBRE_CLIENTE,
        venta.APELLIDO_CLIENTE
    ].filter(Boolean).join(" ") || "—";
    const datosGenerales = crearElemento(
        "div",
        "grid-datos-modal"
    );
    agregarDato(
        datosGenerales,
        "Número de venta",
        venta.ID_VENTA
    );
    agregarDato(
        datosGenerales,
        "Fecha",
        formatearFecha(venta.FECHA_VENTA)
    );
    agregarDato(
        datosGenerales,
        "Cliente",
        cliente
    );
    agregarDato(
        datosGenerales,
        "DNI",
        venta.DNI
    );
    agregarDato(
        datosGenerales,
        "Número de caja",
        venta.NUMERO_CAJA
    );
    agregarDato(
        datosGenerales,
        "Comprobante",
        venta.TIPO_COMPROBANTE
    );
    agregarDato(
        datosGenerales,
        "Cantidad de unidades",
        venta.CANTIDAD_PRODUCTOS
    );
    seccionDatos.appendChild(datosGenerales);
    contenidoDetalleVenta.appendChild(seccionDatos);

    // ==========================================
    // 2. PRODUCTOS VENDIDOS
    // ==========================================

    const seccionProductos = crearSeccionDetalle(
        "Productos vendidos"
    );
    if (productos.length === 0) {
        seccionProductos.appendChild(
            crearElemento(
                "p",
                "",
                "No se encontraron productos."
            )
        );
    } else {
        const filasProductos = productos.map(producto => [
            producto.NOMBRE_PRODUCTO,
            producto.CANTIDAD_VENTA,
            formatearMoneda(producto.PRECIO_UNITARIO),
            formatearMoneda(producto.SUBTOTAL)
        ]);
        const tablaProductos = crearTablaDetalle(
            [
                "Producto",
                "Cantidad",
                "Precio unitario",
                "Subtotal"
            ],
            filasProductos
        );
        const contenedorTabla = crearElemento(
            "div",
            "envoltura-tabla-modal"
        );
        contenedorTabla.appendChild(tablaProductos);
        seccionProductos.appendChild(contenedorTabla);
    }
    contenidoDetalleVenta.appendChild(seccionProductos);

    // ==========================================
    // 3. METODOS DE PAGO
    // ==========================================

    const seccionPagos = crearSeccionDetalle(
        "Métodos de pago"
    );
    if (pagos.length === 0) {
        seccionPagos.appendChild(
            crearElemento(
                "p",
                "",
                "No se encontraron registros de pago."
            )
        );
    } else {
        const filasPagos = pagos.map(pago => [
            pago.METODO_PAGO,
            formatearMoneda(pago.MONTO_PAGO),
            formatearFecha(pago.FECHA_PAGO)
        ]);
        const tablaPagos = crearTablaDetalle(
            [
                "Forma de pago",
                "Importe",
                "Fecha de pago"
            ],
            filasPagos
        );
        const contenedorTablaPagos = crearElemento(
            "div",
            "envoltura-tabla-modal"
        );
        contenedorTablaPagos.appendChild(tablaPagos);
        seccionPagos.appendChild(contenedorTablaPagos);
    }
    contenidoDetalleVenta.appendChild(seccionPagos);

    // ==========================================
    // 4. TOTAL DE LA VENTA
    // ==========================================
    
    const resumenTotal = crearElemento(
        "div",
        "total-modal-detalle"
    );
    const etiquetaTotal = crearElemento(
        "span",
        "",
        "TOTAL DE VENTA"
    );
    const importeTotal = crearElemento(
        "strong",
        "",
        formatearMoneda(venta.TOTAL_VENTA)
    );
    resumenTotal.appendChild(etiquetaTotal);
    resumenTotal.appendChild(importeTotal);
    contenidoDetalleVenta.appendChild(resumenTotal);
}

// Solicita al servidor el detalle de venta, sus productos y pagos desde SQL Server.

async function mostrarDetalleVenta(idVenta, boton) {
    // Evitar consultas repetidas
    boton.disabled = true;
    // Mostrar la ventana emergente
    modalDetalleVenta.showModal();
    tituloModalDetalle.textContent =
        `Detalle de venta N.º ${idVenta}`;
    contenidoDetalleVenta.replaceChildren(
        crearElemento(
            "p",
            "",
            "Consultando información de la venta..."
        )
    );
    try {
        // La API consulta la venta y sus detalles en SQL Server usando este ID.
        const respuesta = await fetch(
            `/api/ventas/${encodeURIComponent(idVenta)}/detalle`
        );
        const datos = await respuesta.json();
        if (!respuesta.ok || !datos.correcto) {
            throw new Error(
                datos.mensaje || "No se pudo consultar el detalle."
            );
        }
        // Mostrar la información recibida
        mostrarDetalleEnModal(datos);
    } catch (error) {
        console.error(
            "Error al consultar el detalle:",
            error
        );
        contenidoDetalleVenta.replaceChildren(
            crearElemento(
                "p",
                "mensaje-error-modal",
                error.message
            )
        );
    } finally {
        boton.disabled = false;
    }
}

//========= CERRAR LA VENTANA EMERGENTE ============

botonCerrarDetalle.addEventListener("click", () => {
    modalDetalleVenta.close();
});

// Permitir cerrar pulsando fuera de la ventana
modalDetalleVenta.addEventListener("click", evento => {
    if (evento.target === modalDetalleVenta) {
        modalDetalleVenta.close();
    }
});


//========== EVENTOS DE LA PAGINA =============

// Buscar mientras se escribe
buscarVenta.addEventListener("input", mostrarVentas);

// Actualizar el historial
botonActualizar.addEventListener("click", cargarVentas);

// Cargar las ventas al abrir la pagina
cargarVentas();