const express = require("express");
const ruta = require("path");
// Driver que conecta Node.js con SQL Server y ejecuta consultas.
const sql = require("mssql");
const session = require("express-session");
require("dotenv").config();

// Crear la aplicación web
const aplicacion = express();

// Definir el puerto
const puerto = 3000;

// Credenciales y opciones que usa el driver para conectarse a SQL Server.
const configuracionSQL = {
    server: process.env.SERVIDOR_SQL,
    user: process.env.USUARIO_SQL,
    password: process.env.CLAVE_SQL,
    database: process.env.BASE_DATOS_SQL,
    options: {
        encrypt: false,
        trustServerCertificate: true
    }
};

// Datos de nuestra caja para las pruebas
const ID_DETALLE_CAJA_PRUEBA = 45;
const NUMERO_CAJA_PRUEBA = 5;

// Permitir recibir datos JSON
aplicacion.use(express.json({ limit: "100kb" }));

// Configurar sesiones de usuario
if (!process.env.SESSION_SECRET) {
    throw new Error("Falta configurar SESSION_SECRET en .env");
}
aplicacion.use(session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
        httpOnly: true,
        sameSite: "lax",
        secure: false,
        maxAge: 30 * 60 * 1000
    }
}));

//======= PROTEGER PAGINAS SEGUN EL ROL ===========
function protegerPagina(rolPermitido) {
    return function(solicitud, respuesta, siguiente) {
        // Comprobar si existe una sesion iniciada
        if (!solicitud.session.usuario ||
            !solicitud.session.rol) {
            return respuesta.redirect("/");
        }
        // Comprobar si el usuario tiene el rol permitido
        if (solicitud.session.rol !== rolPermitido) {
            // Enviar al usuario a su pagina correspondiente
            const paginaCorrecta =
                solicitud.session.rol === "CAJERO"
                    ? "/ventas.html"
                    : "/compras.html";
            return respuesta.redirect(paginaCorrecta);
        }
        siguiente();
    };
}
// El cajero puede acceder a ventas e historial
aplicacion.get(
    "/ventas.html",
    protegerPagina("CAJERO")
);
aplicacion.get(
    "/historial.html",
    protegerPagina("CAJERO")
);
// El reponedor puede acceder a compras
aplicacion.get(
    "/compras.html",
    protegerPagina("REPONEDOR")
);

 //======= PROTEGER PAGINAS SEGUN EL ROL ===========

function protegerPagina(rolPermitido) {
    return function(solicitud, respuesta, siguiente) {
        // Verificar que exista una sesion
        if (!solicitud.session.usuario ||
            !solicitud.session.rol) {
            return respuesta.redirect("/");
        }
        // Verificar el rol del usuario
        if (solicitud.session.rol !== rolPermitido) {
            const paginaCorrecta =
                solicitud.session.rol === "CAJERO"
                    ? "/ventas.html"
                    : "/compras.html";
            return respuesta.redirect(paginaCorrecta);
        }
        siguiente();
    };
}
// Proteger la pagina de ventas
aplicacion.get(
    "/ventas.html",
    protegerPagina("CAJERO")
);
// Proteger el historial de ventas
aplicacion.get(
    "/historial.html",
    protegerPagina("CAJERO")
);
// Proteger la pagina de compras
aplicacion.get(
    "/compras.html",
    protegerPagina("REPONEDOR")
);
// Permitir acceder a los archivos publicos
aplicacion.use(
    express.static(ruta.join(__dirname, "public"))
);

//======= PROTEGER API SEGUN EL ROL ===========

function protegerAPI(rolPermitido = null) {
    return function(solicitud, respuesta, siguiente) {
        // Comprobar si el usuario inicio sesion
        if (
            !solicitud.session.usuario ||
            !solicitud.session.rol
        ) {
            return respuesta.status(401).json({
                correcto: false,
                mensaje: "Debes iniciar sesion para continuar."
            });
        }
        // Comprobar si tiene el rol autorizado
        if (
            rolPermitido &&
            solicitud.session.rol !== rolPermitido
        ) {
            return respuesta.status(403).json({
                correcto: false,
                mensaje: "No tienes permiso para realizar esta operacion."
            });
        }
        siguiente();
    };
}

// Conexion con SQL: requiere iniciar sesion
aplicacion.use(
    "/api/prueba-conexion",
    protegerAPI()
);

// Las categorias son compartidas por ambos modulos
aplicacion.use(
    "/api/categorias",
    protegerAPI()
);

// Productos de ventas: solo cajero
aplicacion.use(
    "/api/productos",
    protegerAPI("CAJERO")
);

// Todas las operaciones de ventas: solo cajero
aplicacion.use(
    "/api/ventas",
    protegerAPI("CAJERO")
);

// Todas las operaciones de compras: solo reponedor
aplicacion.use(
    "/api/compras",
    protegerAPI("REPONEDOR")
);

//======= CERRAR SESION ===========

aplicacion.post("/api/logout", (solicitud, respuesta) => {
    solicitud.session.destroy((error) => {
        if (error) {
            console.error(
                "Error al cerrar sesion:",
                error.message
            );
            return respuesta.status(500).json({
                correcto: false,
                mensaje: "No se pudo cerrar la sesion."
            });
        }
        // Eliminar la cookie de sesion del navegador
        respuesta.clearCookie("connect.sid", {
            httpOnly: true,
            sameSite: "lax",
            secure: false,
            path: "/"
        });
        respuesta.json({
            correcto: true,
            mensaje: "Sesion cerrada correctamente."
        });
    });
});

//======= INICIO DE SESION: AUTENTICAR USUARIO ===========

aplicacion.post("/api/login", async (solicitud, respuesta) => {
    const usuarioIngresado = String(
        solicitud.body?.usuario || ""
    ).trim();
    const contrasena = String(
        solicitud.body?.contrasena || ""
    );
    const usuariosPermitidos = {
        cajero: {
            login: "Cajero",
            rol: "CAJERO"
        },
        reponedor: {
            login: "Reponedor",
            rol: "REPONEDOR"
        }
    };
    const configuracionUsuario =
        usuariosPermitidos[usuarioIngresado.toLowerCase()];
    if (!configuracionUsuario || !contrasena) {
        return respuesta.status(401).json({
            correcto: false,
            mensaje: "Usuario o contraseña incorrectos."
        });
    }
    let conexionUsuario;
    try {
        // Conectar utilizando las credenciales ingresadas
        conexionUsuario = new sql.ConnectionPool({
            ...configuracionSQL,
            user: configuracionUsuario.login,
            password: contrasena
        });
        await conexionUsuario.connect();
        // SQL Server identifica los roles asignados a las credenciales autenticadas.
        const resultado = await conexionUsuario.request().query(`
            SELECT
                CASE
                    WHEN IS_ROLEMEMBER('rol_cajero') = 1
                        THEN 'CAJERO'
                    WHEN IS_ROLEMEMBER('rol_reponedor') = 1
                        THEN 'REPONEDOR'
                    ELSE NULL
                END AS ROL;
        `);
        const rol = resultado.recordset[0].ROL;
        // Verificar que el rol corresponda al usuario
        if (rol !== configuracionUsuario.rol) {
            return respuesta.status(403).json({
                correcto: false,
                mensaje: "El usuario no tiene un rol autorizado."
            });
        }
        // Renovar la sesión para evitar reutilizar una anterior
        await new Promise((resolve, reject) => {
            solicitud.session.regenerate(error => {
                if (error) reject(error);
                else resolve();
            });
        });
        // Guardar los datos de la sesión
        solicitud.session.usuario = configuracionUsuario.login;
        solicitud.session.rol = rol;
        await new Promise((resolve, reject) => {
            solicitud.session.save(error => {
                if (error) reject(error);
                else resolve();
            });
        });
        respuesta.json({
            correcto: true,
            mensaje: "Inicio de sesión correcto.",
            usuario: configuracionUsuario.login,
            rol: rol
        });
    } catch (error) {
        const codigoSQL = Number(
            error.number || error.originalError?.info?.number
        );
        if (error.code === "ELOGIN" || codigoSQL === 18456) {
            return respuesta.status(401).json({
                correcto: false,
                mensaje: "Usuario o contraseña incorrectos."
            });
        }
        console.error(
            "Error al autenticar usuario:",
            error.message
        );
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudo verificar el acceso."
        });
    } finally {
        if (conexionUsuario && conexionUsuario.connected) {
            await conexionUsuario.close().catch(error => {
                console.error(
                    "Error al cerrar conexión de autenticación:",
                    error.message
                );
            });
        }
    }
});

// Crear una ruta para comprobar la conexión con SQL Server
aplicacion.get("/api/prueba-conexion", async (solicitud, respuesta) => {
    try {
        // Abrir la conexión con la base de datos
        const conexion = await sql.connect(configuracionSQL);
        // Lee el nombre de la base y la hora del servidor para comprobar la conexión.
        const resultado = await conexion.request().query(`
            SELECT
                DB_NAME() AS NombreBaseDatos,
                SYSDATETIME() AS FechaHoraServidor;
        `);
        // Devolver el resultado al navegador
        respuesta.json({
            correcto: true,
            mensaje: "Conexión con SQL Server realizada correctamente.",
            datos: resultado.recordset[0]
        });
    } catch (error) {
        // Mostrar el error completo en la terminal para revisarlo
        console.error("Error al conectar con SQL Server:", error.message);
        // Mostrar un mensaje sencillo al usuario
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudo conectar con SQL Server. Revisa la configuración y la terminal."
        });
    }
});

// ======== CONSULTAR LAS CATEGORIAS DE NUESTRA BASE DE DATOS ===============

// Crear una ruta para obtener todas las categorias
aplicacion.get("/api/categorias", async (solicitud, respuesta) => {
    try {
        // Conectar con SQL Server
        const conexion = await sql.connect(configuracionSQL);
        // Lee las categorias y las ordena por nombre para mostrarlas en la aplicacion.
        const resultado = await conexion.request().query(`
            SELECT
                ID_CATEGORIA,
                NOMBRE_CATEGORIA,
                DESCRIP_CATEGORIA
            FROM dbo.CATEGORIA
            ORDER BY NOMBRE_CATEGORIA ASC;
        `);
        // Enviar las categorias encontradas al navegador
        respuesta.json({
            correcto: true,
            cantidad: resultado.recordset.length,
            categorias: resultado.recordset
        });
    } catch (error) {
        // Mostrar el error en la terminal de VS Code
        console.error(
            "Error al consultar las categorias:",
            error.message
        );
        // Informar al navegador que ocurrio un problema
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudieron consultar las categorias."
        });
    }
});

 //======== CONSULTAR PRODUCTOS Y SU STOCK SEGUN LA CATEGORIA =============

 // Crear una ruta que reciba el ID de la categoria
aplicacion.get("/api/productos/:idCategoria", async (solicitud, respuesta) => {
    try {
        // Obtener el ID de la categoria enviada por la pagina
        const idCategoria = Number(solicitud.params.idCategoria);
        // Comprobar que el ID sea un numero entero positivo
        if (!Number.isInteger(idCategoria) || idCategoria <= 0) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "El ID de la categoria no es valido."
            });
        }
        // Conectar con SQL Server
        const conexion = await sql.connect(configuracionSQL);
        // Crea una solicitud SQL independiente para esta consulta.
        const consulta = conexion.request();
        // El parametro tipado evita insertar el dato directamente en el texto SQL.
        consulta.input("idCategoria", sql.Int, idCategoria);
        // Obtiene los productos de la categoria y calcula existencias con sus movimientos.
        const resultado = await consulta.query(`
            SELECT
                P.ID_PRODUCTO,
                P.ID_CATEGORIA,
                P.NOMBRE_PRODUCTO,
                P.DESCRIPCION_PRODUCTO,
                P.PRECIO_VENTA,
                -- Calcular las existencias de cada producto
                ISNULL(I.STOCK_DISPONIBLE, 0) AS STOCK_DISPONIBLE
            FROM dbo.PRODUCTO AS P
            -- Relacionar los productos con sus movimientos
            LEFT JOIN (
                SELECT
                    ID_PRODUCTO,
                    -- Las entradas suman y las salidas restan
                    SUM(
                        CASE
                            WHEN TIPO_MOVIMIENTO = 'E'
                                THEN CANTIDAD_MOVIMIENTO
                            WHEN TIPO_MOVIMIENTO = 'S'
                                THEN -CANTIDAD_MOVIMIENTO
                            ELSE 0
                        END
                    ) AS STOCK_DISPONIBLE
                FROM dbo.MOVIMIENTO_INVENTARIO
                GROUP BY ID_PRODUCTO
            ) AS I
                ON P.ID_PRODUCTO = I.ID_PRODUCTO
            -- Filtrar por la categoria seleccionada
            WHERE P.ID_CATEGORIA = @idCategoria
            ORDER BY P.NOMBRE_PRODUCTO ASC;
        `);
        // Enviar los productos y sus existencias al navegador
        respuesta.json({
            correcto: true,
            categoria: idCategoria,
            cantidad: resultado.recordset.length,
            productos: resultado.recordset
        });
    } catch (error) {
        // Mostrar el error en la terminal
        console.error(
            "Error al consultar productos:",
            error.message
        );
        // Informar al navegador
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudieron consultar los productos."
        });
    }
});


// ======================================================
// REGISTRAR UNA VENTA COMPLETA EN SQL SERVER
// ======================================================

// Esta ruta recibe los datos del carrito, cliente y pago
aplicacion.post("/api/ventas/registrar", async (solicitud, respuesta) => {

    // Variable para controlar la transaccion SQL
    let transaccion = null;

    try {

        // ==========================================
        // 1. RECIBIR LOS DATOS DEL NAVEGADOR
        // ==========================================

        const datos = solicitud.body || {};

        const dni = String(datos.dni || "").trim();
        const nombre = String(datos.nombre || "").trim();
        const apellido = String(datos.apellido || "").trim();

        const idComprobante = Number(datos.idComprobante);
        const idPago = Number(datos.idPago);

        // ==========================================
        // 2. VALIDAR LOS DATOS DEL CLIENTE
        // ==========================================

        if (!/^\d{8}$/.test(dni)) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "El DNI debe contener exactamente 8 numeros."
            });
        }

        if (!nombre || nombre.length > 100) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "El nombre es obligatorio y admite hasta 100 caracteres."
            });
        }

        if (!apellido || apellido.length > 100) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "El apellido es obligatorio y admite hasta 100 caracteres."
            });
        }

        // Comprobar que los identificadores sean validos
        if (
            !Number.isSafeInteger(idComprobante) ||
            idComprobante <= 0 ||
            !Number.isSafeInteger(idPago) ||
            idPago <= 0
        ) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "Selecciona un comprobante y un metodo de pago validos."
            });
        }

        // ==========================================
        // 3. VALIDAR LOS PRODUCTOS RECIBIDOS
        // ==========================================

        if (
            !Array.isArray(datos.productos) ||
            datos.productos.length === 0
        ) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "La venta debe contener al menos un producto."
            });
        }

        // Utilizar un Map para evitar productos repetidos
        const productosNormalizados = new Map();

        for (const item of datos.productos) {

            const idProducto = Number(item.idProducto);
            const cantidad = Number(item.cantidad);

            // Validar identificador y cantidad
            if (
                !Number.isSafeInteger(idProducto) ||
                idProducto <= 0 ||
                !Number.isSafeInteger(cantidad) ||
                cantidad <= 0 ||
                cantidad > 10000
            ) {
                return respuesta.status(400).json({
                    correcto: false,
                    mensaje: "Hay un producto con datos invalidos."
                });
            }

            // Acumular cantidades si llega repetido
            const cantidadAcumulada =
                (productosNormalizados.get(idProducto) || 0) + cantidad;

            if (cantidadAcumulada > 10000) {
                return respuesta.status(400).json({
                    correcto: false,
                    mensaje: "La cantidad solicitada es demasiado grande."
                });
            }

            productosNormalizados.set(
                idProducto,
                cantidadAcumulada
            );
        }

        if (productosNormalizados.size > 100) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "La venta supera el limite de productos."
            });
        }

        // ==========================================
        // 4. INICIAR LA TRANSACCION SQL
        // ==========================================

        const conexion = await sql.connect(configuracionSQL);

        transaccion = new sql.Transaction(conexion);

        // Agrupa la venta completa y SERIALIZABLE protege el stock ante ventas simultaneas.
        await transaccion.begin(sql.ISOLATION_LEVEL.SERIALIZABLE);

        // ==========================================
        // 5. COMPROBAR NUESTRA CAJA DE PRUEBAS
        // ==========================================

        // Verifica que la caja indicada exista y siga abierta; los bloqueos evitan cambios concurrentes.
        const detalleCaja = await new sql.Request(transaccion)
            .input(
                "idDetalle",
                sql.Int,
                ID_DETALLE_CAJA_PRUEBA
            )
            .input(
                "numeroCaja",
                sql.Int,
                NUMERO_CAJA_PRUEBA
            )
            .query(`
                SELECT ID_DETALLE
                FROM dbo.DETALLE_CAJA WITH (UPDLOCK, HOLDLOCK)
                WHERE ID_DETALLE = @idDetalle
                  AND NUMERO_CAJA = @numeroCaja
                  AND HORARIO_FINAL IS NULL;
            `);

        if (detalleCaja.recordset.length === 0) {
            throw Object.assign(
                new Error("El registro de la caja de pruebas no esta disponible."),
                { status: 409 }
            );
        }

        // ==========================================
        // 6. COMPROBAR COMPROBANTE Y METODO DE PAGO
        // ==========================================

        // Confirma en SQL Server que existan el comprobante y el metodo de pago seleccionados.
        const catalogos = await new sql.Request(transaccion)
            .input("idComprobante", sql.Int, idComprobante)
            .input("idPago", sql.Int, idPago)
            .query(`
                SELECT
                    CASE WHEN EXISTS (
                        SELECT 1
                        FROM dbo.COMPROBANTE
                        WHERE ID_COMPROBANTE = @idComprobante
                    ) THEN 1 ELSE 0 END AS ComprobanteValido,

                    CASE WHEN EXISTS (
                        SELECT 1
                        FROM dbo.METODO_PAGO
                        WHERE ID_PAGO = @idPago
                    ) THEN 1 ELSE 0 END AS PagoValido;
            `);

        if (
            !catalogos.recordset[0].ComprobanteValido ||
            !catalogos.recordset[0].PagoValido
        ) {
            throw Object.assign(
                new Error("El comprobante o metodo de pago no existe."),
                { status: 400 }
            );
        }

        // ==========================================
        // 7. COMPROBAR STOCK Y PRECIOS REALES
        // ==========================================

        const productosVerificados = [];

        // Calcular el total en centimos para evitar
        // errores de precision con los decimales
        let totalCentimos = 0;

        // Ordenar los productos para reducir el riesgo
        // de bloqueos entre ventas simultaneas
        const productosOrdenados = Array.from(
            productosNormalizados.entries()
        ).sort((a, b) => a[0] - b[0]);

        for (const [idProducto, cantidad] of productosOrdenados) {

            // Lee precio y stock actuales; los bloqueos mantienen los valores estables durante la venta.
            const resultadoProducto = await new sql.Request(transaccion)
                .input("idProducto", sql.Int, idProducto)
                .query(`
                    SELECT
                        P.ID_PRODUCTO,
                        P.PRECIO_VENTA,

                        ISNULL((
                            SELECT SUM(
                                CASE
                                    WHEN MI.TIPO_MOVIMIENTO = 'E'
                                        THEN MI.CANTIDAD_MOVIMIENTO

                                    WHEN MI.TIPO_MOVIMIENTO = 'S'
                                        THEN -MI.CANTIDAD_MOVIMIENTO

                                    ELSE 0
                                END
                            )
                            FROM dbo.MOVIMIENTO_INVENTARIO AS MI
                            WHERE MI.ID_PRODUCTO = P.ID_PRODUCTO
                        ), 0) AS STOCK_DISPONIBLE

                    FROM dbo.PRODUCTO AS P WITH (UPDLOCK, HOLDLOCK)
                    WHERE P.ID_PRODUCTO = @idProducto;
                `);

            // Comprobar que el producto exista
            if (resultadoProducto.recordset.length === 0) {
                throw Object.assign(
                    new Error("Uno de los productos ya no existe."),
                    { status: 404 }
                );
            }

            const productoBD = resultadoProducto.recordset[0];

            const stockDisponible =
                Number(productoBD.STOCK_DISPONIBLE);

            const precio =
                Number(productoBD.PRECIO_VENTA);

            // Comprobar las existencias actuales
            if (cantidad > stockDisponible) {
                throw Object.assign(
                    new Error(
                        "Stock insuficiente para el producto ID " +
                        idProducto +
                        ". Disponible: " + stockDisponible
                    ),
                    { status: 409 }
                );
            }

            // Comprobar que el precio sea valido
            if (!Number.isFinite(precio) || precio <= 0) {
                throw Object.assign(
                    new Error("El precio de un producto no es valido."),
                    { status: 409 }
                );
            }

            const precioCentimos = Math.round(precio * 100);

            totalCentimos += precioCentimos * cantidad;

            // Guardar el precio obtenido directamente de SQL Server
            productosVerificados.push({
                idProducto: idProducto,
                cantidad: cantidad,
                precioUnitario: Number(
                    (precioCentimos / 100).toFixed(2)
                )
            });
        }

        // La columna MONTO_PAGO admite DECIMAL(10,2)
        if (
            !Number.isSafeInteger(totalCentimos) ||
            totalCentimos <= 0 ||
            totalCentimos > 9999999999
        ) {
            throw Object.assign(
                new Error("El importe total de la venta no es valido."),
                { status: 400 }
            );
        }

        const totalVenta = Number(
            (totalCentimos / 100).toFixed(2)
        );

        // ==========================================
        // 8. BUSCAR O REGISTRAR AL CLIENTE
        // ==========================================

        // Busca al cliente por DNI y bloquea la fila para evitar registros duplicados simultaneos.
        const clienteExistente = await new sql.Request(transaccion)
            .input("dni", sql.Char(8), dni)
            .query(`
                SELECT DNI
                FROM dbo.CLIENTE WITH (UPDLOCK, HOLDLOCK)
                WHERE DNI = @dni;
            `);

        // Si el cliente no existe, registrarlo
        if (clienteExistente.recordset.length === 0) {

            // Registra los datos del cliente solo cuando el DNI aun no existe.
            await new sql.Request(transaccion)
                .input("dni", sql.Char(8), dni)
                .input("nombre", sql.NVarChar(100), nombre)
                .input("apellido", sql.NVarChar(100), apellido)
                .query(`
                    INSERT INTO dbo.CLIENTE (
                        DNI,
                        NOMBRE_CLIENTE,
                        APELLIDO_CLIENTE,
                        FECHA_REGISTRO
                    )
                    VALUES (
                        @dni,
                        @nombre,
                        @apellido,
                        SYSDATETIME()
                    );
                `);
        }

        // Si ya existe, conservamos sus datos registrados.

        // ==========================================
        // 9. REGISTRAR LA VENTA PRINCIPAL
        // ==========================================

        // Inserta la cabecera de la venta y recupera su ID generado por SQL Server.
        const resultadoVenta = await new sql.Request(transaccion)
            .input("idComprobante", sql.Int, idComprobante)
            .input(
                "idDetalle",
                sql.Int,
                ID_DETALLE_CAJA_PRUEBA
            )
            .input("dni", sql.Char(8), dni)
            .query(`
                INSERT INTO dbo.VENTA (
                    ID_COMPROBANTE,
                    ID_DETALLE,
                    DNI,
                    FECHA_VENTA
                )
                VALUES (
                    @idComprobante,
                    @idDetalle,
                    @dni,
                    SYSDATETIME()
                );

                SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID_VENTA;
            `);

        const idVenta = resultadoVenta.recordset[0].ID_VENTA;

        // ==========================================
        // 10. REGISTRAR LOS PRODUCTOS VENDIDOS
        // ==========================================

        for (const producto of productosVerificados) {

            // Guarda cada producto vendido con su cantidad y precio confirmado.
            await new sql.Request(transaccion)
                .input("idVenta", sql.Int, idVenta)
                .input(
                    "idProducto",
                    sql.Int,
                    producto.idProducto
                )
                .input(
                    "cantidad",
                    sql.Int,
                    producto.cantidad
                )
                .input(
                    "precio",
                    sql.Decimal(10, 2),
                    producto.precioUnitario
                )
                .query(`
                    INSERT INTO dbo.DETALLE_VENTA (
                        ID_VENTA,
                        ID_PRODUCTO,
                        CANTIDAD_VENTA,
                        PRECIO_UNITARIO
                    )
                    VALUES (
                        @idVenta,
                        @idProducto,
                        @cantidad,
                        @precio
                    );
                `);

            // Registra el movimiento de salida que descuenta del inventario.
            await new sql.Request(transaccion)
                .input(
                    "idProducto",
                    sql.Int,
                    producto.idProducto
                )
                .input(
                    "cantidad",
                    sql.Int,
                    producto.cantidad
                )
                .query(`
                    INSERT INTO dbo.MOVIMIENTO_INVENTARIO (
                        ID_PRODUCTO,
                        CANTIDAD_MOVIMIENTO,
                        FECHA_MOVIMIENTO,
                        TIPO_MOVIMIENTO
                    )
                    VALUES (
                        @idProducto,
                        @cantidad,
                        SYSDATETIME(),
                        'S'
                    );
                `);
        }

        // ==========================================
        // 11. REGISTRAR EL METODO DE PAGO
        // ==========================================

        // Asocia el metodo de pago y el total de la venta.
        await new sql.Request(transaccion)
            .input("idVenta", sql.Int, idVenta)
            .input("idPago", sql.Int, idPago)
            .input(
                "monto",
                sql.Decimal(10, 2),
                totalVenta
            )
            .query(`
                INSERT INTO dbo.DETALLE_METODO_PAGO (
                    ID_VENTA,
                    ID_PAGO,
                    MONTO_PAGO,
                    FECHA_PAGO
                )
                VALUES (
                    @idVenta,
                    @idPago,
                    @monto,
                    SYSDATETIME()
                );
            `);

        // ==========================================
        // 12. CONFIRMAR TODAS LAS OPERACIONES
        // ==========================================
        // Hace permanentes todas las inserciones de la venta en una sola operacion.
        await transaccion.commit();
        // La transaccion termino correctamente
        transaccion = null;
        // Calcular la cantidad total de unidades
        const cantidadTotal = productosVerificados.reduce(
            (suma, producto) => suma + producto.cantidad,
            0
        );
        // Enviar la confirmacion al navegador
        respuesta.status(201).json({
            correcto: true,
            mensaje: "Venta registrada correctamente.",
            datos: {
                idVenta: idVenta,
                idDetalle: ID_DETALLE_CAJA_PRUEBA,
                numeroCaja: NUMERO_CAJA_PRUEBA,
                cantidadProductos: cantidadTotal,
                total: totalVenta
            }
        });
    } catch (error) {

        // ==========================================
        // 13. REVERTIR SI OCURRE ALGUN ERROR
        // ==========================================
        if (transaccion) {
            try {
                // Revierte cabecera, detalles, inventario y pago si algo fallo.
                await transaccion.rollback();
            } catch (errorReversion) {
                console.error(
                    "Error al revertir la transaccion:",
                    errorReversion.message
                );
            }
        }
        // Mostrar el error completo en VS Code
        console.error(
            "Error al registrar la venta:",
            error.message
        );
        // Informar al navegador
        respuesta.status(error.status || 500).json({
            correcto: false,
            mensaje: error.status
                ? error.message
                : "No se pudo registrar la venta. Revisa la terminal del servidor."
        });
    }
});

//======= CONSULTAR HISTORIAL DE VENTAS =========

aplicacion.get("/api/ventas/historial", async (solicitud, respuesta) => {
    try {
        // Conectar con SQL Server
        const conexion = await sql.connect(configuracionSQL);
        // Recupera las 100 ventas mas recientes con datos de cliente, productos y pagos.
        const resultado = await conexion.request().query(`
            SELECT TOP (100)
                V.ID_VENTA,
                V.FECHA_VENTA,
                V.DNI,
                C.NOMBRE_CLIENTE,
                C.APELLIDO_CLIENTE,
                CB.TIPO_COMPROBANTE,
                DC.NUMERO_CAJA,
                ISNULL(D.CANTIDAD_PRODUCTOS, 0)
                    AS CANTIDAD_PRODUCTOS,
                ISNULL(D.TOTAL_VENTA, 0)
                    AS TOTAL_VENTA,
                ISNULL(P.METODOS_PAGO, '')
                    AS METODOS_PAGO,
                ISNULL(P.MONTO_PAGADO, 0)
                    AS MONTO_PAGADO
            FROM dbo.VENTA AS V
            LEFT JOIN dbo.CLIENTE AS C
                ON V.DNI = C.DNI
            LEFT JOIN dbo.COMPROBANTE AS CB
                ON V.ID_COMPROBANTE = CB.ID_COMPROBANTE
            LEFT JOIN dbo.DETALLE_CAJA AS DC
                ON V.ID_DETALLE = DC.ID_DETALLE
            OUTER APPLY (
                SELECT
                    SUM(DV.CANTIDAD_VENTA)
                        AS CANTIDAD_PRODUCTOS,
                    SUM(
                        DV.CANTIDAD_VENTA * DV.PRECIO_UNITARIO
                    ) AS TOTAL_VENTA
                FROM dbo.DETALLE_VENTA AS DV
                WHERE DV.ID_VENTA = V.ID_VENTA
            ) AS D
            OUTER APPLY (
                SELECT
                    STRING_AGG(
                        CONVERT(NVARCHAR(MAX), MP.METODO_PAGO),
                        ', '
                    ) AS METODOS_PAGO,
                    SUM(DMP.MONTO_PAGO)
                        AS MONTO_PAGADO
                FROM dbo.DETALLE_METODO_PAGO AS DMP
                INNER JOIN dbo.METODO_PAGO AS MP
                    ON DMP.ID_PAGO = MP.ID_PAGO
                WHERE DMP.ID_VENTA = V.ID_VENTA
            ) AS P
            ORDER BY
                V.FECHA_VENTA DESC,
                V.ID_VENTA DESC;
        `);
        // Enviar las ventas al navegador
        respuesta.json({
            correcto: true,
            cantidad: resultado.recordset.length,
            ventas: resultado.recordset
        });
    } catch (error) {
        console.error(
            "Error al consultar el historial de ventas:",
            error.message
        );
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudo consultar el historial de ventas."
        });
    }
});


//======= CONSULTAR EL DETALLE DE UNA VENTA =============

aplicacion.get("/api/ventas/:idVenta/detalle", async (solicitud, respuesta) => {

    try {

        // ==========================================
        // 1. VALIDAR EL ID DE LA VENTA
        // ==========================================

        const idVenta = Number(solicitud.params.idVenta);
        if (!Number.isSafeInteger(idVenta) || idVenta <= 0) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "El numero de venta no es valido."
            });
        }

        // ==========================================
        // 2. CONECTAR CON SQL SERVER
        // ==========================================

        const conexion = await sql.connect(configuracionSQL);

        // ==========================================
        // 3. CONSULTAR LOS DATOS GENERALES
        // ==========================================

        const consultaVenta = conexion.request();
        // Parametro tipado para buscar una venta concreta sin concatenar datos en SQL.
        consultaVenta.input("idVenta", sql.Int, idVenta);
        // Reune datos generales de la venta, cliente, comprobante, caja y totales.
        const resultadoVenta = await consultaVenta.query(`
            SELECT
                V.ID_VENTA,
                V.FECHA_VENTA,
                V.DNI,
                C.NOMBRE_CLIENTE,
                C.APELLIDO_CLIENTE,
                CB.TIPO_COMPROBANTE,
                DC.NUMERO_CAJA,
                ISNULL(D.CANTIDAD_PRODUCTOS, 0)
                    AS CANTIDAD_PRODUCTOS,
                ISNULL(D.TOTAL_VENTA, 0)
                    AS TOTAL_VENTA
            FROM dbo.VENTA AS V
            LEFT JOIN dbo.CLIENTE AS C
                ON V.DNI = C.DNI
            LEFT JOIN dbo.COMPROBANTE AS CB
                ON V.ID_COMPROBANTE = CB.ID_COMPROBANTE
            LEFT JOIN dbo.DETALLE_CAJA AS DC
                ON V.ID_DETALLE = DC.ID_DETALLE
            OUTER APPLY (
                SELECT
                    SUM(DV.CANTIDAD_VENTA)
                        AS CANTIDAD_PRODUCTOS,
                    SUM(
                        DV.CANTIDAD_VENTA * DV.PRECIO_UNITARIO
                    ) AS TOTAL_VENTA
                FROM dbo.DETALLE_VENTA AS DV
                WHERE DV.ID_VENTA = V.ID_VENTA
            ) AS D
            WHERE V.ID_VENTA = @idVenta;
        `);

        // Comprobar que la venta exista
        if (resultadoVenta.recordset.length === 0) {
            return respuesta.status(404).json({
                correcto: false,
                mensaje: "No se encontro la venta solicitada."
            });
        }

        // ==========================================
        // 4. CONSULTAR LOS PRODUCTOS DE LA VENTA
        // ==========================================

        const consultaProductos = conexion.request();
        consultaProductos.input("idVenta", sql.Int, idVenta);
        // Lista los productos vendidos y calcula el subtotal de cada linea.
        const resultadoProductos = await consultaProductos.query(`
            SELECT
                DV.ID_PRODUCTO,
                P.NOMBRE_PRODUCTO,
                DV.CANTIDAD_VENTA,
                DV.PRECIO_UNITARIO,
                (
                    DV.CANTIDAD_VENTA * DV.PRECIO_UNITARIO
                ) AS SUBTOTAL
            FROM dbo.DETALLE_VENTA AS DV
            INNER JOIN dbo.PRODUCTO AS P
                ON DV.ID_PRODUCTO = P.ID_PRODUCTO
            WHERE DV.ID_VENTA = @idVenta
            ORDER BY P.NOMBRE_PRODUCTO ASC;
        `);

        // ==========================================
        // 5. CONSULTAR LOS METODOS DE PAGO
        // ==========================================

        const consultaPagos = conexion.request();
        consultaPagos.input("idVenta", sql.Int, idVenta);
        // Obtiene los metodos de pago usados en la venta y sus montos.
        const resultadoPagos = await consultaPagos.query(`
            SELECT
                MP.ID_PAGO,
                MP.METODO_PAGO,
                DMP.MONTO_PAGO,
                DMP.FECHA_PAGO
            FROM dbo.DETALLE_METODO_PAGO AS DMP
            INNER JOIN dbo.METODO_PAGO AS MP
                ON DMP.ID_PAGO = MP.ID_PAGO
            WHERE DMP.ID_VENTA = @idVenta
            ORDER BY DMP.FECHA_PAGO ASC;
        `);

        // ==========================================
        // 6. ENVIAR TODA LA INFORMACION
        // ==========================================
        respuesta.json({
            correcto: true,
            venta: resultadoVenta.recordset[0],
            productos: resultadoProductos.recordset,
            pagos: resultadoPagos.recordset
        });
    } catch (error) {
        console.error(
            "Error al consultar el detalle de la venta:",
            error.message
        );
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudo consultar el detalle de la venta."
        });
    }
});

//======= MODULO DE COMPRAS: CONSULTAR REPONEDORES ===========

aplicacion.get("/api/compras/reponedores", async (solicitud, respuesta) => {
    try {
        const conexion = await sql.connect(configuracionSQL);
        // Une reponedores con empleados y devuelve solo empleados activos.
        const resultado = await conexion.request().query(`
            SELECT
                E.ID_EMPLEADO,
                E.NOMBRE_EMPLEADO,
                E.APELLIDO_EMPLEADO,
                E.NOMBRE_EMPLEADO + N' ' +
                    E.APELLIDO_EMPLEADO AS NOMBRE_COMPLETO
            FROM dbo.REPONEDOR R
            INNER JOIN dbo.EMPLEADO E
                ON R.ID_EMPLEADO = E.ID_EMPLEADO
            WHERE E.ESTADO_EMPLEADO = 'A'
            ORDER BY E.NOMBRE_EMPLEADO ASC;
        `);
        respuesta.json({
            correcto: true,
            cantidad: resultado.recordset.length,
            reponedores: resultado.recordset
        });
    } catch (error) {
        console.error("Error al consultar reponedores:", error.message);
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudieron consultar los reponedores."
        });
    }
});

//======= MODULO DE COMPRAS: CONSULTAR PROVEEDORES =========

aplicacion.get("/api/compras/proveedores", async (solicitud, respuesta) => {
    try {
        const conexion = await sql.connect(configuracionSQL);
        // Lee los datos de contacto de los proveedores ordenados por nombre.
        const resultado = await conexion.request().query(`
            SELECT
                RUC,
                NOMBRE_PROVEEDOR,
                EMAIL_PROVEEDOR,
                FONO_PROVEEDOR
            FROM dbo.PROVEEDOR
            ORDER BY NOMBRE_PROVEEDOR ASC;
        `);
        respuesta.json({
            correcto: true,
            cantidad: resultado.recordset.length,
            proveedores: resultado.recordset
        });
    } catch (error) {
        console.error("Error al consultar proveedores:", error.message);
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudieron consultar los proveedores."
        });
    }
});

//======= MODULO DE COMPRAS: CATEGORIAS POR PROVEEDOR =======

aplicacion.get("/api/compras/categorias", async (solicitud, respuesta) => { 
    try {
        // Obtener el RUC del proveedor seleccionado.
        const ruc = String(solicitud.query.ruc || "").trim();
        // Validar que el RUC tenga exactamente 11 dígitos.
        if (!/^\d{11}$/.test(ruc)) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "Selecciona un proveedor válido."
            });
        }
        // Conectar con SQL Server.
        const conexion = await sql.connect(configuracionSQL);
        // Preparar el parámetro de búsqueda.
        const consulta = conexion.request();
        consulta.input("ruc", sql.Char(11), ruc);
        // Consultar las categorías que tienen productos
        // suministrados anteriormente por este proveedor.
        const resultado = await consulta.query(`
            SELECT DISTINCT
                C.ID_CATEGORIA,
                C.NOMBRE_CATEGORIA,
                C.DESCRIP_CATEGORIA
            FROM dbo.CATEGORIA AS C
            INNER JOIN dbo.PRODUCTO AS P
                ON C.ID_CATEGORIA = P.ID_CATEGORIA
            WHERE EXISTS (
                -- Comprobar que el producto tenga
                -- compras registradas de este proveedor.
                SELECT 1
                FROM dbo.DETALLE_COMPRA AS DC
                INNER JOIN dbo.COMPRA AS CO
                    ON DC.ID_COMPRA = CO.ID_COMPRA
                WHERE DC.ID_PRODUCTO = P.ID_PRODUCTO
                    AND CO.RUC = @ruc
            )
            ORDER BY C.NOMBRE_CATEGORIA ASC;
        `);
        // Devolver las categorías encontradas.
        respuesta.json({
            correcto: true,
            cantidad: resultado.recordset.length,
            categorias: resultado.recordset
        });
    } catch (error) {
        console.error(
            "Error al consultar categorías por proveedor:",
            error.message
        );
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudieron consultar las categorías del proveedor."
        });
    }
});

//======== MODULO DE COMPRAS: CONSULTAR PRODUCTOS =============

aplicacion.get("/api/compras/productos", async (solicitud, respuesta) => {
    try {
        const conexion = await sql.connect(configuracionSQL);
        // Devuelve productos con categoria y calcula el stock desde sus movimientos.
        const resultado = await conexion.request().query(`
            SELECT
                P.ID_PRODUCTO,
                P.ID_CATEGORIA,
                C.NOMBRE_CATEGORIA,
                P.NOMBRE_PRODUCTO,
                P.DESCRIPCION_PRODUCTO,
                ISNULL(I.STOCK_DISPONIBLE, 0) AS STOCK_DISPONIBLE,
                UC.ULTIMO_COSTO_COMPRA
            FROM dbo.PRODUCTO P
            INNER JOIN dbo.CATEGORIA C
                ON P.ID_CATEGORIA = C.ID_CATEGORIA
            LEFT JOIN (
                SELECT
                    ID_PRODUCTO,
                    SUM(
                        CASE
                            WHEN TIPO_MOVIMIENTO = 'E'
                                THEN CANTIDAD_MOVIMIENTO
                            WHEN TIPO_MOVIMIENTO = 'S'
                                THEN -CANTIDAD_MOVIMIENTO
                            ELSE 0
                        END
                    ) AS STOCK_DISPONIBLE
                FROM dbo.MOVIMIENTO_INVENTARIO
                GROUP BY ID_PRODUCTO
            ) I
            ON P.ID_PRODUCTO = I.ID_PRODUCTO
            OUTER APPLY (
                SELECT TOP (1)
                    DC.COSTO_UNITARIO AS ULTIMO_COSTO_COMPRA
                FROM dbo.DETALLE_COMPRA AS DC
                INNER JOIN dbo.COMPRA AS CO
                    ON CO.ID_COMPRA = DC.ID_COMPRA
                WHERE DC.ID_PRODUCTO = P.ID_PRODUCTO
                ORDER BY
                    CO.FECHA_COMPRA DESC,
                    CO.ID_COMPRA DESC
            ) AS UC
            ORDER BY P.NOMBRE_PRODUCTO ASC;
        `);
        respuesta.json({
            correcto: true,
            cantidad: resultado.recordset.length,
            productos: resultado.recordset
        });
    } catch (error) {
        console.error("Error al consultar productos de compras:", error.message);
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudieron consultar los productos."
        });
    }
});

//========== MODULO DE COMPRAS: HISTORIAL ============

aplicacion.get("/api/compras/historial", async (solicitud, respuesta) => {
    try {
        const conexion = await sql.connect(configuracionSQL);
        // Consulta la vista de compras y muestra las 100 operaciones mas recientes.
        const resultado = await conexion.request().query(`
            SELECT TOP (100)
                ID_COMPRA,
                FECHA_COMPRA,
                PROVEEDOR,
                RUC,
                REGISTRADO_POR,
                PRODUCTOS_DISTINTOS,
                UNIDADES_COMPRADAS,
                TOTAL_COMPRA
            FROM dbo.VW_COMPRAS_PROVEEDOR
            ORDER BY FECHA_COMPRA DESC, ID_COMPRA DESC;
        `);
        respuesta.json({
            correcto: true,
            cantidad: resultado.recordset.length,
            compras: resultado.recordset
        });
    } catch (error) {
        console.error("Error al consultar historial de compras:", error.message);
        respuesta.status(500).json({
            correcto: false,
            mensaje: "No se pudo consultar el historial de compras."
        });
    }
});


//========== MODULO DE COMPRAS: REGISTRAR COMPRA ============

aplicacion.post("/api/compras/registrar", async (solicitud, respuesta) => {
    const { idEmpleado, ruc, productos } = solicitud.body || {};
    // Validar reponedor
    const empleado = Number(idEmpleado);
    if (!Number.isSafeInteger(empleado) || empleado <= 0) {
        return respuesta.status(400).json({
            correcto: false,
            mensaje: "Selecciona un reponedor válido."
        });
    }
    // Validar proveedor
    const rucProveedor = String(ruc || "").trim();
    if (!/^\d{11}$/.test(rucProveedor)) {
        return respuesta.status(400).json({
            correcto: false,
            mensaje: "Selecciona un proveedor válido."
        });
    }
    // Validar productos
    if (!Array.isArray(productos) || productos.length === 0) {
        return respuesta.status(400).json({
            correcto: false,
            mensaje: "Agrega al menos un producto a la compra."
        });
    }
    const productosValidados = [];
    const productosRegistrados = new Set();
    for (const producto of productos) {
        const idProducto = Number(producto.idProducto);
        const cantidad = Number(producto.cantidad);
        const costo = Number(producto.costo);
        if (!Number.isSafeInteger(idProducto) || idProducto <= 0) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "Existe un producto inválido."
            });
        }
        if (!Number.isSafeInteger(cantidad) || cantidad <= 0) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "La cantidad debe ser un número entero mayor a cero."
            });
        }
        const costoCentavos = Math.round(costo * 100);
        if (
            !Number.isFinite(costo) ||
            costo <= 0 ||
            costo > 99999999.99 ||
            Math.abs(costo * 100 - costoCentavos) > 0.000001
        ) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "El costo debe ser mayor a cero y tener máximo dos decimales."
            });
        }
        if (productosRegistrados.has(idProducto)) {
            return respuesta.status(400).json({
                correcto: false,
                mensaje: "No puedes agregar dos veces el mismo producto."
            });
        }
        productosRegistrados.add(idProducto);
        productosValidados.push({
            idProducto,
            cantidad,
            costo: costoCentavos / 100
        });
    }
    // Una transaccion asegura que la compra y sus productos se guarden juntos o no se guarde nada.
    let transaccion;
    let transaccionIniciada = false;
    try {
        const conexion = await sql.connect(configuracionSQL);
        transaccion = new sql.Transaction(conexion);
        await transaccion.begin();
        transaccionIniciada = true;
        // Llama al procedimiento almacenado que crea la cabecera y devuelve el ID de compra.
        const resultadoCompra = await new sql.Request(transaccion)
            .input("ID_EMPLEADO", sql.Int, empleado)
            .input("RUC", sql.Char(11), rucProveedor)
            .output("ID_COMPRA", sql.Int)
            .execute("dbo.SP_REGISTRAR_COMPRA");
        const idCompra = Number(resultadoCompra.output.ID_COMPRA);
        if (!Number.isSafeInteger(idCompra) || idCompra <= 0) {
            throw new Error("No se pudo obtener el número de compra.");
        }
        // El procedimiento agrega cada producto y actualiza la compra dentro de la misma transaccion.
        for (const producto of productosValidados) {
            await new sql.Request(transaccion)
                .input("ID_COMPRA", sql.Int, idCompra)
                .input("ID_PRODUCTO", sql.Int, producto.idProducto)
                .input("CANTIDAD", sql.Int, producto.cantidad)
                .input("COSTO", sql.Decimal(10, 2), producto.costo)
                .execute("dbo.SP_AGREGAR_PRODUCTO_COMPRA");
        }
        // Confirma de forma permanente la cabecera y todos sus productos.
        await transaccion.commit();
        transaccionIniciada = false;
        respuesta.json({
            correcto: true,
            mensaje: "Compra registrada correctamente.",
            idCompra: idCompra,
            cantidadProductos: productosValidados.length,
            unidades: productosValidados.reduce(
                (total, producto) => total + producto.cantidad,
                0
            )
        });
    } catch (error) {
        // Si ocurre un error, revierte la compra completa para no dejar datos parciales.
        if (transaccion && transaccionIniciada) {
            try {
                await transaccion.rollback();
            } catch (errorRollback) {
                console.error(
                    "Error al cancelar la transacción:",
                    errorRollback.message
                );
            }
        }
        const codigoError = Number(
            error.number || error.originalError?.info?.number
        );
        const mensajeSQL =
            error.originalError?.info?.message ||
            error.precedingErrors?.[0]?.message ||
            error.message;
        console.error("Error al registrar compra:", mensajeSQL);
        const errorControlado =
            codigoError >= 50000 && codigoError < 60000;
        respuesta.status(errorControlado ? 400 : 500).json({
            correcto: false,
            mensaje: errorControlado
                ? mensajeSQL
                : "No se pudo registrar la compra. Revisa la terminal."
        });
    }
});

// Iniciar el servidor web
aplicacion.listen(puerto, () => {
    console.log(
        `Mi Barrio Market disponible en http://localhost:${puerto}`
    );
});