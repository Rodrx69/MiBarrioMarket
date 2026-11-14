//======== OBTENER LOS ELEMENTOS DE NUESTRA PAGINA ============

const selectorCategoria = document.getElementById("categoria");
const detalleCategoria = document.getElementById("detalle-categoria");
const listadoProductos = document.getElementById("listado-productos");
const mensajeCategorias = document.getElementById("mensaje-categorias");

// Solicita al servidor las categorias que obtiene desde SQL Server.

async function cargarCategorias() {
    try {
        // Pide las categorias a la API; el navegador no se conecta directamente a SQL Server.
        const respuesta = await fetch("/api/categorias");
        // Convertir la respuesta a JSON
        const resultado = await respuesta.json();
        // Comprobar si la consulta fue correcta
        if (!respuesta.ok || !resultado.correcto) {
            throw new Error("No se pudieron cargar las categorias.");
        }
        // Limpiar la lista desplegable
        selectorCategoria.innerHTML = "";
        // Crear la opcion inicial
        const opcionInicial = document.createElement("option");
        opcionInicial.value = "";
        opcionInicial.textContent = "Seleccionar categoria";
        selectorCategoria.appendChild(opcionInicial);
        // Recorrer todas las categorias
        resultado.categorias.forEach(function(categoria) {
            // Crear una opcion para cada categoria
            const opcion = document.createElement("option");
            // Guardar el identificador
            opcion.value = categoria.ID_CATEGORIA;
            // Mostrar el nombre
            opcion.textContent = categoria.NOMBRE_CATEGORIA;
            // Guardar la descripcion
            opcion.dataset.descripcion = categoria.DESCRIP_CATEGORIA;
            // Agregar a la lista
            selectorCategoria.appendChild(opcion);
        });
        // Mostrar la cantidad de categorias cargadas
        mensajeCategorias.textContent =
            resultado.cantidad + " categorias cargadas correctamente.";
    } catch (error) {
        console.error("Error al cargar categorias:", error.message);
        mensajeCategorias.textContent =
            "No se pudieron cargar las categorias.";
    }
}

// Pide al servidor los productos y el stock calculado para la categoria elegida.
async function cargarProductos(idCategoria) {
    try {
        // Mostrar un mensaje mientras se consultan los productos
        listadoProductos.textContent = "Cargando productos...";
        // El servidor consulta SQL Server y devuelve los productos de esta categoria.
        const respuesta = await fetch(
            "/api/productos/" + encodeURIComponent(idCategoria)
        );
        // Convertir la respuesta a JSON
        const resultado = await respuesta.json();
        // Comprobar si la consulta fue correcta
        if (!respuesta.ok || !resultado.correcto) {
            throw new Error("No se pudieron consultar los productos.");
        }
        // Limpiar el listado anterior
        listadoProductos.innerHTML = "";
        // Comprobar si existen productos
        if (resultado.productos.length === 0) {
            listadoProductos.textContent =
                "No hay productos registrados en esta categoria.";
            return;
        }
        // Recorrer todos los productos encontrados
        resultado.productos.forEach(function(producto) {
            // Crear la tarjeta del producto
            const tarjeta = document.createElement("article");
            tarjeta.className = "tarjeta-producto";
            // Crear el nombre del producto
            const nombre = document.createElement("h3");
            nombre.textContent = producto.NOMBRE_PRODUCTO;
            // Crear la descripcion
            const descripcion = document.createElement("p");
            descripcion.textContent =
                producto.DESCRIPCION_PRODUCTO || "Sin descripcion disponible.";
            // Crear el precio
            const precio = document.createElement("p");
            precio.className = "precio-producto";
            precio.textContent = Number(producto.PRECIO_VENTA).toLocaleString(
                "es-PE",
                {
                    style: "currency",
                    currency: "PEN"
                }
            );
            // Agregar los elementos a la tarjeta
            tarjeta.appendChild(nombre);
            tarjeta.appendChild(descripcion);
            tarjeta.appendChild(precio);
            // Agregar la tarjeta al listado
            listadoProductos.appendChild(tarjeta);
        });
    } catch (error) {
        // Mostrar el error en la terminal
        console.error("Error al consultar productos:", error.message);
        // Informar al usuario
        listadoProductos.textContent =
            "No se pudieron cargar los productos.";
    }
}
//======== DETECTAR CUANDO SE SELECCIONA UNA CATEGORIA ===========
selectorCategoria.addEventListener("change", async function() {
    // Obtener la categoria seleccionada
    const categoriaSeleccionada =
        selectorCategoria.selectedOptions[0];
    // Comprobar si se selecciono una categoria
    if (!selectorCategoria.value) {
        detalleCategoria.textContent =
            "Selecciona una categoria para ver su descripcion.";
        listadoProductos.textContent =
            "Selecciona una categoria para ver sus productos.";
        return;
    }
    // Mostrar la descripcion correspondiente
    detalleCategoria.textContent =
        categoriaSeleccionada.dataset.descripcion;
    // Consultar los productos de esa categoria
    await cargarProductos(selectorCategoria.value);
});
// ====== INICIAR LA CARGA DE CATEGORIAS =============
cargarCategorias();