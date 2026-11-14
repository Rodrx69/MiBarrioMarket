-- CREAMOS NUESTRA BASE DE DATOS
CREATE DATABASE BASE_DATOS_MI_BARRIO_MARKET;

-- USAMOS NUESTRA BASE DE DATOS
USE BASE_DATOS_MI_BARRIO_MARKET;

-- CREAMOS LA TABLA CATEGORIA
CREATE TABLE CATEGORIA(
    ID_CATEGORIA INT IDENTITY (1,1) PRIMARY KEY,
    NOMBRE_CATEGORIA NVARCHAR (50) NOT NULL,
    DESCRIP_CATEGORIA NVARCHAR (100) NOT NULL,
    CONSTRAINT UNIQUE_NOMBRE_CATEG UNIQUE (NOMBRE_CATEGORIA)
);

-- CREAMOS LA TABLA CLIENTE
CREATE TABLE CLIENTE (x
    DNI CHAR (8) PRIMARY KEY,
    NOMBRE_CLIENTE NVARCHAR (50) NOT NULL,
    APELLIDO_CLIENTE NVARCHAR (50) NOT NULL,
    FECHA_REGISTRO DATETIME NOT NULL,
    CONSTRAINT CHECK_CLIENTE_DNI CHECK (DNI NOT LIKE '%[^0-9]%' AND LEN(DNI) = 8)
);

-- CREAMOS LA TABLA PROVEEDOR
CREATE TABLE PROVEEDOR(
    RUC CHAR (11) PRIMARY KEY,
    NOMBRE_PROVEEDOR NVARCHAR(50) NOT NULL,
    EMAIL_PROVEEDOR NVARCHAR(50) NOT NULL,
    FONO_PROVEEDOR CHAR (9) NOT NULL,
    CONSTRAINT CHECK_RUC_PROVEEDOR CHECK (RUC NOT LIKE '%[^0-9]%' AND LEN(RUC) = 11),
    CONSTRAINT CHECK_EMAIL_PROVEEDOR CHECK (EMAIL_PROVEEDOR LIKE '%_@_%._%' AND EMAIL_PROVEEDOR NOT LIKE '% %'),
    CONSTRAINT CHECK_FONO_PROVEEDOR CHECK (FONO_PROVEEDOR NOT LIKE '%[^0-9]%' AND LEN(FONO_PROVEEDOR) = 9 AND LEFT(FONO_PROVEEDOR, 1) = '9')
);

-- CREAMOS LA TABLA METODO_PAGO
CREATE TABLE METODO_PAGO(
    ID_PAGO INT IDENTITY (1,1) PRIMARY KEY,
    METODO_PAGO NVARCHAR (25) NOT NULL
);

-- CREAMOS LA TABLA COMPROBANTE
CREATE TABLE COMPROBANTE(
    ID_COMPROBANTE INT IDENTITY (1,1) PRIMARY KEY,
    TIPO_COMPROBANTE NVARCHAR(20) NOT NULL,
    CONSTRAINT CHECK_COMPROBANTE_TIPO CHECK (TIPO_COMPROBANTE IN ('BOLETA','FACTURA','TICKET'))
);

-- CREAMOS LA TABLA CAJA
CREATE TABLE CAJA(
    NUMERO_CAJA INT PRIMARY KEY,
    ESTADO_CAJA CHAR (1) NOT NULL, -- CAJA: A = Abierta, C = Cerrada
    MONTO_APERTURA DECIMAL (10,2) NOT NULL,
    MONTO_CIERRE DECIMAL (10,2) NULL,
    CONSTRAINT CHECK_CAJA_ESTADO CHECK (ESTADO_CAJA IN ('A','C')),
    CONSTRAINT CHECK_CAJA_NUMERO CHECK (NUMERO_CAJA >= 1 AND NUMERO_CAJA <= 5),
    CONSTRAINT CHECK_CAJA_MONTOS CHECK (MONTO_APERTURA >= 0 AND MONTO_CIERRE >= 0)
);

-- CREAMOS LA TABLA EMPLEADO
CREATE TABLE EMPLEADO(
    ID_EMPLEADO INT IDENTITY (1,1) PRIMARY KEY,
    NOMBRE_EMPLEADO NVARCHAR (50) NOT NULL,
    APELLIDO_EMPLEADO NVARCHAR (50) NOT NULL,
    FECHA_CONTRATO DATE NOT NULL,
    ESTADO_EMPLEADO CHAR (1) NOT NULL, -- (A: ACTIVO, I: INACTIVO)
    EMAIL_EMPLEADO VARCHAR (100) NOT NULL,
    SUELDO_BASE DECIMAL (10,2) NOT NULL,
    FONO_EMPLEADO CHAR (9) NOT NULL,
    CONSTRAINT CHECK_EMPLEADO_ESTADO CHECK (ESTADO_EMPLEADO IN ('A','I')),
    CONSTRAINT CHECK_EMPLEADO_SUELDO CHECK (SUELDO_BASE > 0),
    CONSTRAINT CHECK_EMPLEADO_EMAIL CHECK (EMAIL_EMPLEADO LIKE '%_@_%._%' AND EMAIL_EMPLEADO NOT LIKE '% %'),
    CONSTRAINT CHECK_EMPLEADO_FONO CHECK (FONO_EMPLEADO NOT LIKE '%[^0-9]%' AND LEN(FONO_EMPLEADO) = 9 AND LEFT(FONO_EMPLEADO, 1) = '9')
);

-- CREAMOS LA TABLA CAJERO
CREATE TABLE CAJERO(
    ID_EMPLEADO INT NOT NULL,
    TURNO NVARCHAR (10) NOT NULL,
    CONSTRAINT PK_CAJERO PRIMARY KEY (ID_EMPLEADO),
    CONSTRAINT FK_CAJERO_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO(ID_EMPLEADO),
    CONSTRAINT CHECK_CAJERO_TURNO CHECK (TURNO IN ('MAÑANA','TARDE','NOCHE'))
);

-- CREAMOS LA TABLA REPONEDOR
CREATE TABLE REPONEDOR(
    ID_EMPLEADO INT NOT NULL,
    HORAS_EXTRAS INT NOT NULL,
    CONSTRAINT PK_REPONEDOR PRIMARY KEY (ID_EMPLEADO),
    CONSTRAINT FK_REPONEDOR_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO(ID_EMPLEADO),
    CONSTRAINT CHECK_REPONEDOR_HORAS CHECK (HORAS_EXTRAS >= 0)
);

-- CREAMOS LA TABLA PRODUCTO
CREATE TABLE PRODUCTO(
    ID_PRODUCTO INT IDENTITY(1,1) PRIMARY KEY,
    ID_CATEGORIA INT NOT NULL,
    NOMBRE_PRODUCTO NVARCHAR(150) NOT NULL,
    DESCRIPCION_PRODUCTO NVARCHAR(255) NULL,
    PRECIO_VENTA DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_PRODUCTO_CATEGORIA FOREIGN KEY (ID_CATEGORIA) REFERENCES CATEGORIA(ID_CATEGORIA),
    CONSTRAINT CHECK_PRODUCTO_PRECIO CHECK (PRECIO_VENTA > 0)
);

-- CREAMOS LA TABLA DETALLE_CAJA
CREATE TABLE DETALLE_CAJA (
    ID_DETALLE INT IDENTITY(1,1) PRIMARY KEY,
    ID_EMPLEADO INT NOT NULL,
    NUMERO_CAJA INT NOT NULL,
    HORARIO_INICIO DATETIME NOT NULL,
    HORARIO_FINAL DATETIME NULL,
    CONSTRAINT FK_DETALLECAJA_CAJERO FOREIGN KEY (ID_EMPLEADO) REFERENCES CAJERO(ID_EMPLEADO),
    CONSTRAINT FK_DETALLECAJA_CAJA FOREIGN KEY (NUMERO_CAJA) REFERENCES CAJA(NUMERO_CAJA),
    CONSTRAINT CHECK_DETALLECAJA_HORARIO CHECK (HORARIO_FINAL IS NULL OR HORARIO_FINAL >= HORARIO_INICIO)
);

-- CREAMOS LA TABLA MOVIMIENTO_INVENTARIO
CREATE TABLE MOVIMIENTO_INVENTARIO (
    ID_MOVIMIENTO INT IDENTITY(1,1) PRIMARY KEY,
    ID_PRODUCTO INT NOT NULL,
    CANTIDAD_MOVIMIENTO INT NOT NULL,
    FECHA_MOVIMIENTO DATETIME NOT NULL,
    TIPO_MOVIMIENTO CHAR(1) NOT NULL, -- (E = ENTRADA DEL PRODUCTOS, S = SALIDA DE PRODUCTOS)
    CONSTRAINT FK_MOV_PRODUCTO FOREIGN KEY (ID_PRODUCTO) REFERENCES PRODUCTO(ID_PRODUCTO),
    CONSTRAINT CHECK_MOV_TIPO CHECK (TIPO_MOVIMIENTO IN ('E','S')),
    CONSTRAINT CHECK_MOV_CANTIDAD CHECK (CANTIDAD_MOVIMIENTO > 0)
);

-- CREAMO LA TABLA COMPRA
CREATE TABLE COMPRA (
    ID_COMPRA INT IDENTITY(1,1) PRIMARY KEY,
    ID_EMPLEADO INT NOT NULL,
    RUC CHAR(11) NOT NULL,
    FECHA_COMPRA DATETIME NOT NULL,
    CONSTRAINT FK_COMPRA_EMPLEADO FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO(ID_EMPLEADO),
    CONSTRAINT FK_COMPRA_PROVEEDOR FOREIGN KEY (RUC) REFERENCES PROVEEDOR(RUC)
);

-- CREAMOS LA TABLA DETALLE_COMPRA
CREATE TABLE DETALLE_COMPRA (
    ID_COMPRA INT NOT NULL,
    ID_PRODUCTO INT NOT NULL,
    CANTIDAD_COMPRADA INT NOT NULL,
    COSTO_UNITARIO DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DETALLE_COMPRA PRIMARY KEY (ID_COMPRA, ID_PRODUCTO),
    CONSTRAINT FK_DETCOMPRA_COMPRA FOREIGN KEY (ID_COMPRA) REFERENCES COMPRA(ID_COMPRA),
    CONSTRAINT FK_DETCOMPRA_PRODUCTO FOREIGN KEY (ID_PRODUCTO) REFERENCES PRODUCTO(ID_PRODUCTO),
    CONSTRAINT CHECK_DETCOMPRA_CANTIDAD CHECK (CANTIDAD_COMPRADA > 0),
    CONSTRAINT CHECK_DETCOMPRA_COSTO CHECK (COSTO_UNITARIO > 0)
);

-- CREAMOS LA TABLA VENTA
CREATE TABLE VENTA (
    ID_VENTA INT IDENTITY(1,1) PRIMARY KEY,
    ID_COMPROBANTE INT NOT NULL,
    ID_DETALLE INT NOT NULL, -- RELACIONADO AL TURNO / CAJA 
    DNI CHAR(8) NOT NULL,
    FECHA_VENTA DATETIME NOT NULL,
    CONSTRAINT FK_VENTA_COMPROBANTE FOREIGN KEY (ID_COMPROBANTE) REFERENCES COMPROBANTE(ID_COMPROBANTE),
    CONSTRAINT FK_VENTA_DETALLECAJA FOREIGN KEY (ID_DETALLE) REFERENCES DETALLE_CAJA(ID_DETALLE),
    CONSTRAINT FK_VENTA_CLIENTE FOREIGN KEY (DNI) REFERENCES CLIENTE(DNI)
);

-- CREAMOS LA TABLA DETALLE_VENTA
CREATE TABLE DETALLE_VENTA (
    ID_VENTA INT NOT NULL,
    ID_PRODUCTO INT NOT NULL,
    CANTIDAD_VENTA INT NOT NULL,
    PRECIO_UNITARIO DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_DETALLE_VENTA PRIMARY KEY (ID_VENTA, ID_PRODUCTO),
    CONSTRAINT FK_DETVENTA_VENTA FOREIGN KEY (ID_VENTA) REFERENCES VENTA(ID_VENTA),
    CONSTRAINT FK_DETVENTA_PRODUCTO FOREIGN KEY (ID_PRODUCTO) REFERENCES PRODUCTO(ID_PRODUCTO),
    CONSTRAINT CHECK_DETVENTA_CANTIDAD CHECK (CANTIDAD_VENTA > 0),
    CONSTRAINT CHECK_DETVENTA_PRECIO CHECK (PRECIO_UNITARIO > 0)
);

-- CREAMOS LA TABLA DETALLE_METODO_PAGO
CREATE TABLE DETALLE_METODO_PAGO (
    ID_VENTA INT NOT NULL,
    ID_PAGO INT NOT NULL,
    MONTO_PAGO DECIMAL(10,2) NOT NULL,
    FECHA_PAGO DATETIME NOT NULL,
    CONSTRAINT PK_DETALLE_METODO_PAGO PRIMARY KEY (ID_VENTA, ID_PAGO),
    CONSTRAINT FK_DETPAGO_VENTA FOREIGN KEY (ID_VENTA) REFERENCES VENTA(ID_VENTA),
    CONSTRAINT FK_DETPAGO_PAGO FOREIGN KEY (ID_PAGO) REFERENCES METODO_PAGO(ID_PAGO),
    CONSTRAINT CHECK_DETPAGO_MONTO CHECK (MONTO_PAGO > 0)
);

-- COMENZAMOS A INSERTAR DATOS EN NUESTRO PROYECTO PARA PODER TRABAJAR

-- INSERTAMOS DATOS EN LA TABLA CATEGORIA
INSERT INTO CATEGORIA (NOMBRE_CATEGORIA, DESCRIP_CATEGORIA) VALUES
('Abarrotes',           'Arroz, azúcar, fideos, aceite y productos de despensa'),
('Lácteos',             'Leche, yogurt, queso y mantequilla'),
('Bebidas',             'Gaseosas, jugos, agua y bebidas energizantes'),
('Snacks',              'Galletas, papas fritas, chocolates y golosinas'),
('Limpieza',            'Detergentes, lejía, jabones y desinfectantes'),
('Cuidado Personal',    'Shampoo, jabón de baño, pasta dental y desodorantes'),
('Carnes y Embutidos',  'Pollo, jamón, hot dog y chorizo'),
('Panadería',           'Pan, pasteles y productos de panadería'),
('Frutas y Verduras',   'Frutas y verduras frescas de temporada'),
('Mascotas',            'Alimento, snacks y accesorios para perros, gatos y otras mascotas'),
('Licores y Cervezas',  'Cervezas, vinos, pisco y otras bebidas alcohólicas'),
('Bebés y Niños',       'Pañales, toallitas húmedas, leche en polvo y papillas');

-- INSERTAMOS DATOS EN LA TABLA PRODUCTO
INSERT INTO PRODUCTO (ID_CATEGORIA, NOMBRE_PRODUCTO, DESCRIPCION_PRODUCTO, PRECIO_VENTA) VALUES
-- 1) ABARROTES
(1,  N'Azúcar rubia 1 kg',              N'Azúcar rubia, bolsa de 1 kg',                     4.80),
(1,  N'Fideos spaghetti 500 g',         N'Fideos spaghetti, bolsa de 500 g',                3.90),
(1,  N'Atún en aceite vegetal 170 g',   N'Conserva de atún en aceite, lata de 170 g',       5.50),
(1,  N'Arroz extra 5 kg',               N'Arroz superior, bolsa de 5 kg',                   24.90),
(1,  N'Aceite vegetal 1 L',             N'Aceite vegetal, botella de 1 litro',              9.50),
(1,  N'Lentejas 500 g',                 N'Lentejas secas, bolsa de 500 g',                  6.50),
(1,  N'Harina preparada 1 kg',          N'Harina preparada para hot cakes, bolsa de 1 kg',  5.90),
(1,  N'Sal de mesa yodada 1 kg',        N'Sal yodada de mesa, bolsa de 1 kg',               2.20),
(1,  N'Avena en hojuelas 400 g',        N'Avena en hojuelas, bolsa de 400 g',               4.50),
(1,  N'Salsa de tomate 400 g',          N'Salsa de tomate para cocinar, doypack de 400 g',  4.20),
-- 2) LÁCTEOS
(2,  N'Queso fresco 250 g',             N'Queso fresco de vaca, paquete de 250 g',          8.90),
(2,  N'Mantequilla con sal 200 g',      N'Mantequilla con sal, barra de 200 g',             7.50),
(2,  N'Leche UHT entera 1 L',           N'Leche entera de larga duración, caja de 1 L',     5.20),
(2,  N'Leche evaporada 400 g',          N'Leche evaporada entera, lata de 400 g',           4.20),
(2,  N'Yogurt de fresa 1 L',            N'Yogurt bebible sabor fresa, botella 1 L',         7.80),
(2,  N'Leche condensada 393 g',         N'Leche condensada azucarada, lata de 393 g',       6.80),
(2,  N'Queso edam 250 g',               N'Queso edam en paquete de 250 g',                  11.90),
(2,  N'Yogurt natural 1 L',             N'Yogurt natural sin azúcar, botella de 1 litro',   7.20),
(2,  N'Crema de leche 200 g',           N'Crema de leche en caja de 200 g',                 4.90),
(2,  N'Yogurt griego 150 g',            N'Yogurt griego natural, vaso de 150 g',            3.20),
-- 3) BEBIDAS
(3,  N'Jugo de naranja 1 L',            N'Néctar de naranja, caja de 1 litro',              5.90),
(3,  N'Bebida energizante 473 ml',      N'Bebida energizante, lata de 473 ml',              6.50),
(3,  N'Té helado limón 500 ml',         N'Té helado sabor limón, botella de 500 ml',        3.20),
(3,  N'Gaseosa 1.5 L',                  N'Gaseosa sabor tradicional, botella 1.5 L',        7.50),
(3,  N'Agua sin gas 625 ml',            N'Agua de mesa sin gas, botella 625 ml',            1.80),
(3,  N'Agua con gas 625 ml',            N'Agua de mesa con gas, botella de 625 ml',         2.00),
(3,  N'Gaseosa cola 3 L',               N'Gaseosa sabor cola, botella de 3 litros',         11.50),
(3,  N'Jugo de manzana 1 L',            N'Néctar de manzana, caja de 1 litro',              5.90),
(3,  N'Bebida isotónica 500 ml',        N'Bebida hidratante, botella de 500 ml',            4.00),
(3,  N'Chicha morada 1 L',              N'Refresco de maíz morado, botella de 1 litro',     6.00),
-- 4) SNACKS
(4,  N'Chocolate en barra 40 g',        N'Barra de chocolate con leche de 40 g',            2.50),
(4,  N'Galletas de soda x6',            N'Paquete de 6 galletas de soda',                   2.20),
(4,  N'Maní salado 100 g',              N'Maní tostado y salado, bolsa de 100 g',           3.50),
(4,  N'Galletas rellenas de fresa x6',  N'Paquete de 6 galletas rellenas',                  3.50),
(4,  N'Papas fritas clásicas 150 g',    N'Piqueo de papas fritas, bolsa de 150 g',          6.00),
(4,  N'Chifles de plátano 120 g',       N'Chifles de plátano salados, bolsa de 120 g',      4.50),
(4,  N'Gomitas surtidas 100 g',         N'Gomitas de frutas surtidas, bolsa de 100 g',      3.80),
(4,  N'Barra de cereal 25 g',           N'Barra de cereal con frutas, 25 g',                1.80),
(4,  N'Galletas de avena x6',           N'Paquete de 6 galletas de avena',                  3.20),
(4,  N'Canchita mantequilla 100 g',     N'Canchita dulce con mantequilla, bolsa de 100 g',  3.00),
-- 5) LIMPIEZA
(5,  N'Lavavajillas en crema 400 g',    N'Lavavajillas en crema, pote de 400 g',            6.50),
(5,  N'Desinfectante multiuso 900 ml',  N'Desinfectante líquido para pisos y superficies',  8.90),
(5,  N'Esponja multiusos x3',           N'Paquete de 3 esponjas de cocina',                 3.50),
(5,  N'Detergente en polvo 800 g',      N'Detergente para ropa, bolsa de 800 g',            14.90),
(5,  N'Lejía 1 L',                      N'Lejía desinfectante, botella de 1 litro',         4.50),
(5,  N'Limpiavidrios 500 ml',           N'Limpiavidrios con gatillo, botella de 500 ml',    7.90),
(5,  N'Suavizante de telas 900 ml',     N'Suavizante de ropa, botella de 900 ml',           11.50),
(5,  N'Bolsas para basura x10',         N'Paquete de 10 bolsas para basura',                3.90),
(5,  N'Jabón de ropa en barra 250 g',   N'Jabón en barra para lavar ropa, 250 g',           3.20),
(5,  N'Ambientador en aerosol 360 ml',  N'Ambientador en aerosol aroma lavanda, 360 ml',    9.90),
-- 6) CUIDADO PERSONAL
(6,  N'Jabón de baño 120 g',            N'Jabón de tocador en barra, 120 g',                2.80),
(6,  N'Desodorante en barra 50 g',      N'Desodorante antitranspirante en barra, 50 g',     9.90),
(6,  N'Cepillo dental suave',           N'Cepillo dental de cerdas suaves',                 4.50),
(6,  N'Shampoo anticaspa 375 ml',       N'Shampoo anticaspa, frasco de 375 ml',             18.90),
(6,  N'Pasta dental 75 ml',             N'Crema dental con flúor, tubo de 75 ml',           5.90),
(6,  N'Acondicionador 375 ml',          N'Acondicionador para cabello, frasco de 375 ml',   18.50),
(6,  N'Enjuague bucal 250 ml',          N'Enjuague bucal sabor menta, frasco de 250 ml',    12.90),
(6,  N'Papel higiénico doble hoja x4',  N'Paquete de 4 rollos de papel higiénico',          7.50),
(6,  N'Toallas higiénicas x10',         N'Paquete de 10 toallas higiénicas con alas',       5.90),
(6,  N'Máquina de afeitar x2',          N'Paquete de 2 máquinas de afeitar descartables',   4.20),
-- 7) CARNES Y EMBUTIDOS
(7,  N'Hot dog de pollo 500 g',         N'Salchichas de pollo, paquete de 500 g',           12.50),
(7,  N'Chorizo parrillero 400 g',       N'Chorizo parrillero, paquete de 400 g',            14.90),
(7,  N'Pechuga de pollo fileteada (kg)',N'Pechuga de pollo fileteada, precio por kilo',     17.90),
(7,  N'Pollo entero fresco (kg)',       N'Pollo entero fresco, precio por kilo',            11.50),
(7,  N'Jamón inglés 200 g',             N'Jamón inglés envasado, paquete de 200 g',         9.90),
(7,  N'Salchicha tipo viena 250 g',     N'Salchichas tipo viena, paquete de 250 g',         6.90),
(7,  N'Jamonada 200 g',                 N'Jamonada envasada, paquete de 200 g',             6.50),
(7,  N'Muslo de pollo (kg)',            N'Muslo de pollo fresco, precio por kilo',          12.90),
(7,  N'Carne molida de res (kg)',       N'Carne molida de res fresca, precio por kilo',     24.90),
(7,  N'Tocino ahumado 200 g',           N'Tocino ahumado en láminas, paquete de 200 g',     11.90),
-- 8) PANADERIA
(8,  N'Pan ciabatta x4',                N'Bolsa de 4 panes ciabatta',                       6.00),
(8,  N'Queque de vainilla 250 g',       N'Queque de vainilla empacado, 250 g',              8.50),
(8,  N'Empanada de pollo',              N'Empanada horneada rellena de pollo',              3.50),
(8,  N'Pan francés x10',                N'Bolsa de 10 panes franceses',                     3.00),
(8,  N'Pan de molde integral',          N'Pan de molde integral, bolsa grande',             7.50),
(8,  N'Pan de molde blanco',            N'Pan de molde blanco, bolsa grande',               6.50),
(8,  N'Croissant de mantequilla',       N'Croissant horneado con mantequilla',              2.50),
(8,  N'Pan para hamburguesa x6',        N'Bolsa de 6 panes para hamburguesa',               5.50),
(8,  N'Alfajor de manjar blanco',       N'Alfajor relleno de manjar blanco',                2.00),
(8,  N'Pan chapla x4',                  N'Bolsa de 4 panes chapla',                         3.50),
-- 9) FRUTAS Y VERDURAS 
(9,  N'Papa blanca (kg)',               N'Papa blanca fresca, precio por kilo',             3.50),
(9,  N'Cebolla roja (kg)',              N'Cebolla roja fresca, precio por kilo',            3.20),
(9,  N'Manzana (kg)',                   N'Manzana fresca de temporada, precio por kilo',    6.50),
(9,  N'Plátano de seda (kg)',           N'Plátano de seda fresco, precio por kilo',         3.80),
(9,  N'Tomate (kg)',                    N'Tomate fresco, precio por kilo',                  4.50),
(9,  N'Zanahoria (kg)',                 N'Zanahoria fresca, precio por kilo',               2.80),
(9,  N'Limón (kg)',                     N'Limón fresco, precio por kilo',                   6.50),
(9,  N'Palta fuerte (kg)',              N'Palta fuerte fresca, precio por kilo',            12.90),
(9,  N'Naranja de jugo (kg)',           N'Naranja para jugo, precio por kilo',              3.20),
(9,  N'Lechuga americana (unid)',       N'Lechuga americana fresca, precio por unidad',     2.50),
-- 10) PRODUCTOS PARA MASCOTAS
(10, N'Alimento para gato adulto 1 kg', N'Alimento seco para gatos adultos, 1 kg',          13.90),
(10, N'Snack para perro 100 g',         N'Snack masticable para perros, bolsa de 100 g',    6.90),
(10, N'Shampoo para mascotas 250 ml',   N'Shampoo suave para perros y gatos, 250 ml',       16.90),
(10, N'Alimento para perro adulto 1 kg',N'Alimento seco para perros adultos, 1 kg',         12.50),
(10, N'Arena para gatos 4 kg',          N'Arena sanitaria absorbente, bolsa de 4 kg',       15.90),
(10, N'Alimento para gatito 1 kg',      N'Alimento seco para gatitos, 1 kg',                14.90),
(10, N'Alimento para cachorro 1 kg',    N'Alimento seco para perros cachorros, 1 kg',       13.50),
(10, N'Snack para gato 50 g',           N'Snack cremoso para gatos, sobre de 50 g',         4.50),
(10, N'Pelota de goma para perro',      N'Pelota de goma resistente para perros',           7.90),
(10, N'Comedero doble para mascotas',   N'Comedero doble de plástico para perros y gatos', 12.90),
-- 11) LICORES Y CERVEZAS
(11, N'Cerveza rubia lata 355 ml',      N'Cerveza rubia en lata de 355 ml',                 4.50),
(11, N'Cerveza rubia botella 620 ml',   N'Cerveza rubia en botella de 620 ml',              7.50),
(11, N'Pisco quebranta 750 ml',         N'Pisco puro quebranta, botella de 750 ml',         35.90),
(11, N'Vino tinto 750 ml',              N'Vino tinto semiseco, botella de 750 ml',          29.90),
(11, N'Ron añejo 750 ml',               N'Ron añejo, botella de 750 ml',                    39.90),
(11, N'Cerveza negra botella 620 ml',   N'Cerveza negra en botella de 620 ml',              8.50),
(11, N'Cerveza rubia six pack 355 ml',  N'Six pack de cerveza rubia en lata de 355 ml',     24.90),
(11, N'Vino blanco 750 ml',             N'Vino blanco semiseco, botella de 750 ml',         27.90),
(11, N'Pisco acholado 750 ml',          N'Pisco acholado, botella de 750 ml',               32.90),
(11, N'Vodka 750 ml',                   N'Vodka, botella de 750 ml',                        36.90),
-- 12) BEBES Y NIÑOS
(12, N'Pañales talla M x30',            N'Pañales descartables talla M, paquete de 30',     39.90),
(12, N'Toallitas húmedas x80',          N'Toallitas húmedas para bebé, paquete de 80',      11.90),
(12, N'Leche en polvo etapa 1 400 g',   N'Fórmula infantil en polvo, lata de 400 g',        42.90),
(12, N'Papilla de cereal 200 g',        N'Papilla de cereal con frutas, caja de 200 g',     9.50),
(12, N'Shampoo para bebé 200 ml',       N'Shampoo suave para bebé, frasco de 200 ml',       14.90),
(12, N'Pañales talla G x30',            N'Pañales descartables talla G, paquete de 30',     42.90),
(12, N'Crema antipañalitis 100 g',      N'Crema protectora, tubo de 100 g',                 12.90),
(12, N'Leche en polvo etapa 2 400 g',   N'Fórmula de continuación en polvo, lata de 400 g', 44.90),
(12, N'Biberón 250 ml',                 N'Biberón de plástico libre de BPA, 250 ml',        14.90),
(12, N'Talco para bebé 200 g',          N'Talco suave para bebé, frasco de 200 g',          9.90);

-- INSERTAMOS DATOS EN LA TABLA CLIENTE
INSERT INTO CLIENTE (DNI, NOMBRE_CLIENTE, APELLIDO_CLIENTE, FECHA_REGISTRO) VALUES
('78473414', N'Héctor',         N'Sánchez Tello',   '20260706 16:54:00'),
('69812467', N'Walter',         N'Montalvo Cano',   '20260708 17:37:00'),
('65656198', N'Yesenia',        N'Paredes Rojas',   '20260709 11:05:00'),
('53639945', N'Sofía Mariela',  N'Zevallos Arce',   '20260712 14:26:00'),
('41691947', N'Patricia',       N'Aguilar Rey',     '20260718 12:26:00'),
('32077262', N'Carmen Rosa',    N'Delgado Ríos',    '20260719 16:07:00'),
('13202177', N'Milagros',       N'Cruz Villanueva', '20260801 12:46:00'),
('78952666', N'Renzo',          N'Rojas Alva',      '20260809 19:48:00'),
('58571567', N'Óscar',          N'Rivera Campos',   '20260811 10:25:00'),
('33815115', N'Jorge Luis',     N'Pérez Gómez',     '20260820 08:14:00'),
('61004739', N'Lucía Fernanda', N'Quiroz Pinedo',   '20260825 15:22:00'),
('66856101', N'Miguel Ángel',   N'Torres Palomino', '20260826 15:42:00'),
('28347213', N'Gabriela',       N'Bustamante Ruiz', '20260903 11:02:00'),
('58889548', N'César',          N'Medina Cáceres',  '20260907 09:23:00'),
('57484484', N'Nataly',         N'Castillo Flores', '20260909 14:03:00'),
('58276962', N'Fabiola',        N'Mamani Condori',  '20260911 09:14:00'),
('31633837', N'Brayan',         N'Vargas Luna',     '20260912 12:35:00'),
('33718954', N'Andrés',         N'Fernández Cueva', '20260912 16:23:00'),
('34406620', N'Daniela',        N'Lozano Meza',     '20260913 08:58:00'),
('52743665', N'Juan Carlos',    N'Huamán Quispe',   '20260918 16:53:00'),
('69830097', N'Flor de María',  N'Valdez Soto',     '20260919 18:37:00'),
('33298688', N'Raúl',           N'Ortega Bravo',    '20260922 08:04:00'),
('40950967', N'Diego Alonso',   N'Chávez Mendoza',  '20260927 16:41:00'),
('78481085', N'Verónica',       N'Espinoza León',   '20260929 10:54:00'),
('43541247', N'Rocío',          N'Salazar Ortiz',   '20261006 12:48:00'),
('75768555', N'Elías',          N'Ramos Díaz',      '20261009 15:14:00'),
('76849210', N'Víctor',         N'Carrasco Vera',   '20261009 16:37:00'),
('63668769', N'Karina',         N'Gutiérrez Silva', '20261014 13:31:00'),
('71928958', N'Mauricio',       N'Núñez Salas',     '20261014 15:35:00'),
('47460468', N'Ximena',         N'Tapia Guerra',    '20261015 09:01:00');

-- INSERTAMOS DATOS EN LA TABLA PROVEEDOR
INSERT INTO PROVEEDOR (RUC, NOMBRE_PROVEEDOR, EMAIL_PROVEEDOR, FONO_PROVEEDOR) VALUES
('20601234567', N'Distribuidora Andina S.A.C.', 'ventas@andina.com.pe',             '987654321'),
('20512345678', N'Lácteos del Valle S.A.C.',    'pedidos@lacteosvalle.com.pe',      '976543210'),
('20498765432', N'Bebidas del Perú S.A.',       'contacto@bebidasperu.com.pe',      '965432109'),
('20556677889', N'Limpio Hogar E.I.R.L.',       'ventas@limpiohogar.com.pe',        '954321098'),
('20458912367', N'Avícola Santa Rosa S.A.C.',   'pedidos@avicolasantarosa.com.pe',  '943210987'),
('20601122334', N'Agro Fresco Perú S.A.C.',     'ventas@agrofresco.com.pe',         '932109876'),
('20534567891', N'El Buen Pan S.A.C.',          'pedidos@elbuenpan.com.pe',         '921098765'),
('20615062180', N'Family Pets E & E S.A.C.',    'info@familypets.com',              '910987654');

-- INSERTAMOS DATOS EN LA TABLA METODO_PAGO
INSERT INTO METODO_PAGO (METODO_PAGO) VALUES
(N'Efectivo'),
(N'Tarjeta de crédito'),
(N'Tarjeta de débito'),
(N'Yape'),
(N'Plin');

-- INSERTAMOS DATOS EN LA TABLA COMPROBANTE
INSERT INTO COMPROBANTE (TIPO_COMPROBANTE) VALUES
(N'BOLETA'),
(N'FACTURA'),
(N'TICKET');

-- INSERTAMOS DATOS EN LA TABLA CAJA
INSERT INTO CAJA (NUMERO_CAJA, ESTADO_CAJA, MONTO_APERTURA, MONTO_CIERRE) VALUES
(1, 'A', 200.00, NULL),
(2, 'C', 200.00, 326.42),
(3, 'C', 150.00, 242.00),
(4, 'C', 150.00, 206.00),
(5, 'A', 100.00, NULL);

-- INSERTAMOS DATOS EN LA TABLA EMPLEADO
INSERT INTO EMPLEADO (NOMBRE_EMPLEADO, APELLIDO_EMPLEADO, FECHA_CONTRATO, ESTADO_EMPLEADO, EMAIL_EMPLEADO, SUELDO_BASE, FONO_EMPLEADO) VALUES
(N'Carlos Alberto',     'Ramírez Soto',     '20240115', 'A', 'carlos.ramirez@mibarriomarket.com',   1500.00, '987123456'),
(N'María Fernanda',     'Quispe Huamán',    '20240301', 'A', 'maria.quispe@mibarriomarket.com',     1400.00, '976234567'),
(N'Luis Miguel',        'Torres Vega',      '20240610', 'A', 'luis.torres@mibarriomarket.com',      1400.00, '965345678'),
(N'Ana Lucía',          'Flores Cárdenas',  '20250120', 'A', 'ana.flores@mibarriomarket.com',       1300.00, '954456789'),
(N'José Antonio',       'Mendoza Rojas',    '20230905', 'A', 'jose.mendoza@mibarriomarket.com',     1450.00, '943567890'),
(N'Rosa Elena',         'Castillo Paredes', '20240218', 'A', 'rosa.castillo@mibarriomarket.com',    1350.00, '932678901'),
(N'Pedro Pablo',        'Vargas Lima',      '20250310', 'A', 'pedro.vargas@mibarriomarket.com',     1300.00, '921789012');

-- INSERTAMOS DATOS EN LA TABLA CAJERO
INSERT INTO CAJERO (ID_EMPLEADO, TURNO) VALUES
(1, N'MAÑANA'),
(2, N'TARDE'),
(3, N'MAÑANA'),
(4, N'TARDE');

-- INSERTAMOS DATOS EN LA TABLA REPONEDOR
INSERT INTO REPONEDOR (ID_EMPLEADO, HORAS_EXTRAS) VALUES
(5, 8),
(6, 5),
(7, 3);

-- INSERTAMOS DATOS EN LA TABLA DETALLE_CAJA
 INSERT INTO DETALLE_CAJA (ID_EMPLEADO, NUMERO_CAJA, HORARIO_INICIO, HORARIO_FINAL) VALUES
(1, 1, '20261005 07:00:00', '20261005 15:00:00'),
(2, 2, '20261005 15:00:00', '20261005 23:00:00'),
(3, 3, '20261006 07:00:00', '20261006 15:00:00'),
(4, 4, '20261006 15:00:00', '20261006 23:00:00'),
(1, 1, '20261007 07:00:00', '20261007 15:00:00'),
(2, 2, '20261007 15:00:00', '20261007 23:00:00'),
(3, 3, '20261008 07:00:00', '20261008 15:00:00'),
(4, 4, '20261008 15:00:00', '20261008 23:00:00'),
(1, 1, '20261009 07:00:00', '20261009 15:00:00'),
(2, 2, '20261009 15:00:00', '20261009 23:00:00'),
(1, 1, '20261010 07:00:00', '20261010 15:00:00'),
(3, 5, '20261010 07:00:00', '20261010 15:00:00'),
(2, 2, '20261010 15:00:00', '20261010 23:00:00'),
(4, 4, '20261010 15:00:00', '20261010 23:00:00'),
(3, 3, '20261011 07:00:00', '20261011 15:00:00'),
(4, 4, '20261011 15:00:00', '20261011 23:00:00'),
(1, 1, '20261012 07:00:00', '20261012 15:00:00'),
(2, 2, '20261012 15:00:00', '20261012 23:00:00'),
(3, 3, '20261013 07:00:00', '20261013 15:00:00'),
(4, 4, '20261013 15:00:00', '20261013 23:00:00'),
(1, 1, '20261014 07:00:00', '20261014 15:00:00'),
(2, 2, '20261014 15:00:00', '20261014 23:00:00'),
(3, 3, '20261015 07:00:00', '20261015 15:00:00'),
(4, 4, '20261015 15:00:00', '20261015 23:00:00'),
(1, 1, '20261016 07:00:00', '20261016 15:00:00'),
(2, 2, '20261016 15:00:00', '20261016 23:00:00'),
(1, 1, '20261017 07:00:00', '20261017 15:00:00'),
(3, 5, '20261017 07:00:00', '20261017 15:00:00'),
(2, 2, '20261017 15:00:00', '20261017 23:00:00'),
(4, 4, '20261017 15:00:00', '20261017 23:00:00'),
(3, 3, '20261018 07:00:00', '20261018 15:00:00'),
(4, 4, '20261018 15:00:00', '20261018 23:00:00'),
(1, 1, '20261019 07:00:00', '20261019 15:00:00'),
(2, 2, '20261019 15:00:00', '20261019 23:00:00'),
(3, 3, '20261020 07:00:00', '20261020 15:00:00'),
(4, 4, '20261020 15:00:00', '20261020 23:00:00'),
(1, 1, '20261021 07:00:00', '20261021 15:00:00'),
(2, 2, '20261021 15:00:00', '20261021 23:00:00'),
(3, 3, '20261022 07:00:00', '20261022 15:00:00'),
(4, 4, '20261022 15:00:00', '20261022 23:00:00'),
(1, 1, '20261023 07:00:00', '20261023 15:00:00'),
(2, 2, '20261023 15:00:00', '20261023 23:00:00'),
(1, 1, '20261024 07:00:00', '20261024 15:00:00'),
(3, 5, '20261024 15:00:00', '20261024 23:00:00');

-- INSERTAMOS DATOS EN LA TABLA COMPRA

INSERT INTO COMPRA (ID_EMPLEADO, RUC, FECHA_COMPRA) VALUES
(5, '20601234567', '20261003 06:05:00'),
(6, '20498765432', '20261003 06:15:00'),
(7, '20556677889', '20261003 06:20:00'),
(5, '20615062180', '20261003 06:40:00'),
(6, '20512345678', '20261004 06:10:00'),
(7, '20458912367', '20261004 06:25:00'),
(5, '20601122334', '20261004 06:30:00'),
(6, '20534567891', '20261004 06:35:00'),
(7, '20512345678', '20261008 06:10:00'),
(5, '20458912367', '20261008 06:25:00'),
(6, '20601122334', '20261008 06:30:00'),
(7, '20534567891', '20261008 06:35:00'),
(5, '20601234567', '20261010 06:05:00'),
(6, '20498765432', '20261010 06:15:00'),
(7, '20556677889', '20261010 06:20:00'),
(5, '20615062180', '20261010 06:40:00'),
(6, '20512345678', '20261011 06:10:00'),
(7, '20458912367', '20261011 06:25:00'),
(5, '20601122334', '20261011 06:30:00'),
(6, '20534567891', '20261011 06:35:00'),
(7, '20512345678', '20261015 06:10:00'),
(5, '20458912367', '20261015 06:25:00'),
(6, '20601122334', '20261015 06:30:00'),
(7, '20534567891', '20261015 06:35:00'),
(5, '20601234567', '20261017 06:05:00'),
(6, '20498765432', '20261017 06:15:00'),
(7, '20556677889', '20261017 06:20:00'),
(5, '20615062180', '20261017 06:40:00'),
(6, '20512345678', '20261018 06:10:00'),
(7, '20458912367', '20261018 06:25:00'),
(5, '20601122334', '20261018 06:30:00'),
(6, '20534567891', '20261018 06:35:00'),
(7, '20512345678', '20261022 06:10:00'),
(5, '20458912367', '20261022 06:25:00'),
(6, '20601122334', '20261022 06:30:00'),
(7, '20534567891', '20261022 06:35:00'),
(5, '20601234567', '20261024 06:05:00'),
(6, '20498765432', '20261024 06:15:00'),
(7, '20556677889', '20261024 06:20:00'),
(5, '20615062180', '20261024 06:40:00'),
(6, '20512345678', '20261024 06:10:00'),
(7, '20458912367', '20261024 06:25:00'),
(5, '20601122334', '20261024 06:30:00'),
(6, '20534567891', '20261024 06:35:00');

-- INSERTAMOS DATOS EN LA TABLA DETALLE_COMPRA

INSERT INTO DETALLE_COMPRA (ID_COMPRA, ID_PRODUCTO, CANTIDAD_COMPRADA, COSTO_UNITARIO) VALUES
(1, 1, 54, 3.57),
(1, 2, 48, 2.75),
(1, 3, 42, 4.33),
(1, 4, 27, 17.93),
(1, 5, 36, 7.29),
(1, 16, 32, 1.70),
(1, 17, 48, 1.57),
(1, 18, 144, 2.45),
(1, 19, 56, 2.73),
(1, 20, 30, 4.38),
(2, 11, 42, 4.34),
(2, 12, 54, 5.01),
(2, 13, 192, 2.20),
(2, 14, 108, 5.26),
(2, 15, 80, 1.26),
(2, 51, 72, 3.14),
(2, 52, 24, 5.34),
(2, 53, 15, 27.99),
(2, 54, 12, 22.66),
(2, 55, 12, 29.10),
(3, 21, 24, 4.70),
(3, 22, 42, 6.12),
(3, 23, 40, 2.62),
(3, 24, 24, 11.13),
(3, 25, 30, 3.44),
(3, 26, 24, 2.16),
(3, 27, 36, 7.81),
(3, 28, 24, 3.23),
(3, 29, 30, 13.76),
(3, 30, 30, 4.11),
(4, 46, 24, 10.30),
(4, 47, 36, 5.08),
(4, 48, 36, 13.05),
(4, 49, 24, 8.61),
(4, 50, 24, 11.21),
(4, 56, 15, 31.07),
(4, 57, 24, 8.91),
(4, 58, 12, 31.02),
(4, 59, 30, 6.70),
(4, 60, 36, 11.48),
(5, 6, 54, 6.70),
(5, 7, 54, 5.76),
(5, 8, 42, 3.87),
(5, 9, 32, 2.97),
(5, 10, 24, 5.87),
(6, 31, 24, 8.94),
(6, 32, 36, 10.79),
(6, 33, 24, 12.89),
(6, 34, 24, 8.31),
(6, 35, 18, 6.92),
(7, 41, 40, 2.57),
(7, 42, 48, 2.41),
(7, 43, 42, 4.61),
(7, 44, 88, 2.95),
(7, 45, 24, 3.45),
(8, 36, 36, 4.65),
(8, 37, 30, 6.75),
(8, 38, 88, 2.64),
(8, 39, 40, 2.33),
(8, 40, 30, 5.81),
(9, 6, 108, 6.84),
(9, 7, 108, 5.88),
(9, 8, 36, 3.87),
(9, 9, 56, 2.94),
(9, 10, 24, 5.87),
(10, 31, 24, 9.03),
(10, 32, 54, 10.58),
(10, 33, 66, 13.02),
(10, 34, 36, 8.40),
(10, 35, 30, 7.06),
(11, 41, 48, 2.52),
(11, 42, 32, 2.41),
(11, 43, 30, 4.61),
(11, 44, 24, 2.92),
(11, 45, 36, 3.45),
(12, 36, 42, 4.60),
(12, 37, 30, 6.75),
(12, 38, 32, 2.67),
(12, 39, 40, 2.35),
(12, 40, 24, 5.70),
(13, 1, 144, 3.57),
(13, 2, 192, 2.75),
(13, 3, 144, 4.24),
(13, 4, 54, 17.93),
(13, 5, 66, 7.14),
(13, 16, 96, 1.70),
(13, 17, 40, 1.56),
(13, 18, 40, 2.50),
(13, 19, 144, 2.70),
(13, 20, 108, 4.29),
(14, 11, 60, 4.39),
(14, 12, 24, 5.01),
(14, 13, 96, 2.18),
(14, 14, 66, 5.20),
(14, 15, 144, 1.27),
(14, 51, 72, 3.20),
(14, 52, 30, 5.34),
(14, 53, 15, 28.27),
(14, 54, 18, 22.22),
(14, 55, 18, 28.81),
(15, 21, 18, 4.70),
(15, 22, 36, 6.12),
(15, 23, 40, 2.67),
(15, 24, 54, 11.35),
(15, 25, 66, 3.51),
(15, 26, 96, 2.21),
(15, 27, 30, 7.65),
(15, 28, 66, 3.23),
(15, 29, 36, 13.63),
(15, 30, 30, 4.11),
(16, 46, 30, 10.20),
(16, 47, 24, 5.03),
(16, 48, 24, 13.05),
(16, 49, 36, 8.70),
(16, 50, 42, 11.21),
(16, 56, 18, 31.07),
(16, 57, 24, 8.73),
(16, 58, 12, 30.72),
(16, 59, 36, 6.83),
(16, 60, 36, 11.48),
(17, 6, 60, 6.84),
(17, 7, 36, 5.76),
(17, 8, 36, 3.87),
(17, 9, 48, 2.94),
(17, 10, 42, 5.87),
(18, 31, 108, 9.03),
(18, 32, 42, 10.58),
(18, 33, 36, 12.89),
(18, 34, 24, 8.31),
(18, 35, 42, 7.06),
(19, 41, 72, 2.57),
(19, 42, 32, 2.46),
(19, 43, 36, 4.65),
(19, 44, 48, 2.92),
(19, 45, 42, 3.48),
(20, 36, 42, 4.55),
(20, 37, 36, 6.75),
(20, 38, 24, 2.70),
(20, 39, 48, 2.38),
(20, 40, 24, 5.81),
(21, 6, 24, 6.77),
(21, 7, 24, 5.76),
(21, 8, 72, 3.80),
(21, 9, 40, 2.94),
(21, 10, 36, 5.87),
(22, 31, 36, 8.94),
(22, 32, 54, 10.68),
(22, 33, 24, 13.15),
(22, 34, 24, 8.48),
(22, 35, 36, 6.92),
(23, 41, 56, 2.52),
(23, 42, 96, 2.43),
(23, 43, 36, 4.56),
(23, 44, 48, 2.95),
(23, 45, 24, 3.45),
(24, 36, 42, 4.55),
(24, 37, 30, 6.61),
(24, 38, 32, 2.70),
(24, 39, 96, 2.35),
(24, 40, 30, 5.76),
(25, 1, 72, 3.60),
(25, 2, 80, 2.70),
(25, 3, 54, 4.24),
(25, 4, 36, 18.29),
(25, 5, 144, 7.22),
(25, 16, 192, 1.72),
(25, 17, 80, 1.54),
(25, 18, 192, 2.45),
(25, 19, 144, 2.73),
(25, 20, 60, 4.29),
(26, 11, 144, 4.43),
(26, 12, 108, 5.11),
(26, 13, 192, 2.18),
(26, 14, 72, 5.15),
(26, 15, 192, 1.26),
(26, 51, 72, 3.17),
(26, 52, 24, 5.29),
(26, 53, 27, 27.71),
(26, 54, 30, 22.22),
(26, 55, 9, 28.81),
(27, 21, 108, 4.70),
(27, 22, 54, 6.12),
(27, 23, 32, 2.62),
(27, 24, 54, 11.35),
(27, 25, 60, 3.47),
(27, 26, 72, 2.16),
(27, 27, 54, 7.73),
(27, 28, 60, 3.17),
(27, 29, 24, 13.76),
(27, 30, 36, 4.15),
(28, 46, 30, 10.20),
(28, 47, 24, 5.08),
(28, 48, 24, 13.05),
(28, 49, 30, 8.70),
(28, 50, 30, 11.21),
(28, 56, 18, 31.07),
(28, 57, 36, 8.82),
(28, 58, 18, 30.42),
(28, 59, 36, 6.70),
(28, 60, 30, 11.48),
(29, 6, 66, 6.70),
(29, 7, 18, 5.88),
(29, 8, 42, 3.80),
(29, 9, 40, 2.94),
(29, 10, 42, 5.87),
(30, 31, 30, 9.03),
(30, 32, 36, 10.79),
(30, 33, 24, 13.02),
(30, 34, 30, 8.31),
(30, 35, 54, 6.92),
(31, 41, 40, 2.55),
(31, 42, 40, 2.41),
(31, 43, 24, 4.56),
(31, 44, 24, 2.95),
(31, 45, 36, 3.52),
(32, 36, 54, 4.55),
(32, 37, 36, 6.61),
(32, 38, 88, 2.67),
(32, 39, 32, 2.35),
(32, 40, 24, 5.76),
(33, 6, 54, 6.77),
(33, 7, 24, 5.82),
(33, 8, 42, 3.80),
(33, 9, 32, 2.97),
(33, 10, 24, 5.99),
(34, 31, 42, 8.94),
(34, 32, 24, 10.58),
(34, 33, 24, 13.02),
(34, 34, 54, 8.31),
(34, 35, 36, 6.92),
(35, 41, 32, 2.52),
(35, 42, 40, 2.46),
(35, 43, 30, 4.56),
(35, 44, 72, 2.95),
(35, 45, 24, 3.45),
(36, 36, 24, 4.60),
(36, 37, 24, 6.61),
(36, 38, 48, 2.67),
(36, 39, 32, 2.38),
(36, 40, 66, 5.70),
(37, 61, 60, 4.40),
(37, 62, 48, 4.00),
(37, 63, 96, 1.45),
(37, 64, 72, 3.05),
(37, 65, 60, 2.85),
(37, 76, 72, 3.00),
(37, 77, 72, 2.55),
(37, 78, 120, 1.15),
(37, 79, 96, 2.10),
(37, 80, 72, 1.95),
(38, 71, 120, 1.30),
(38, 72, 48, 8.10),
(38, 73, 60, 3.95),
(38, 74, 72, 2.70),
(38, 75, 48, 4.00),
(38, 111, 48, 6.00),
(38, 112, 36, 18.00),
(38, 113, 24, 20.00),
(38, 114, 24, 24.00),
(38, 115, 18, 27.00),
(39, 81, 36, 5.40),
(39, 82, 36, 8.00),
(39, 83, 72, 2.55),
(39, 84, 72, 2.10),
(39, 85, 36, 6.80),
(39, 86, 30, 13.20),
(39, 87, 36, 9.00),
(39, 88, 60, 5.10),
(39, 89, 60, 3.95),
(39, 90, 60, 2.85),
(40, 106, 36, 10.60),
(40, 107, 36, 9.50),
(40, 108, 60, 3.00),
(40, 109, 36, 5.20),
(40, 110, 24, 8.70),
(40, 116, 30, 31.00),
(40, 117, 36, 8.90),
(40, 118, 24, 33.00),
(40, 119, 30, 9.90),
(40, 120, 36, 6.60),
(41, 66, 48, 4.70),
(41, 67, 36, 8.40),
(41, 68, 48, 5.00),
(41, 69, 48, 3.30),
(41, 70, 72, 2.15),
(42, 91, 48, 4.80),
(42, 92, 48, 4.40),
(42, 93, 40, 9.10),
(42, 94, 30, 18.20),
(42, 95, 36, 8.30),
(43, 101, 60, 1.85),
(43, 102, 40, 4.50),
(43, 103, 36, 9.00),
(43, 104, 72, 2.10),
(43, 105, 48, 1.60),
(44, 96, 48, 4.50),
(44, 97, 72, 1.60),
(44, 98, 48, 3.70),
(44, 99, 96, 1.30),
(44, 100, 60, 2.35);

-- INSERTAMOS DATOS EN LA TABLA VENTA

INSERT INTO VENTA (ID_COMPROBANTE, ID_DETALLE, DNI, FECHA_VENTA) VALUES
(3, 1, '78473414', '20261005 08:28:33'),
(1, 1, '57484484', '20261005 10:09:06'),
(2, 1, '66856101', '20261005 10:16:15'),
(2, 1, '61004739', '20261005 11:51:09'),
(1, 2, '33718954', '20261005 17:32:59'),
(1, 2, '57484484', '20261005 18:59:14'),
(1, 2, '41691947', '20261005 20:40:59'),
(3, 2, '57484484', '20261005 21:06:47'),
(1, 3, '33815115', '20261006 08:26:46'),
(3, 3, '34406620', '20261006 12:14:42'),
(3, 3, '13202177', '20261006 13:32:00'),
(1, 4, '33815115', '20261006 15:28:19'),
(3, 4, '69812467', '20261006 15:41:00'),
(1, 4, '40950967', '20261006 16:21:55'),
(3, 4, '33718954', '20261006 16:38:01'),
(2, 4, '57484484', '20261006 17:28:09'),
(1, 5, '41691947', '20261007 08:02:21'),
(2, 5, '33815115', '20261007 11:17:36'),
(1, 5, '33815115', '20261007 12:56:50'),
(1, 6, '40950967', '20261007 15:27:08'),
(1, 6, '61004739', '20261007 19:47:34'),
(1, 6, '61004739', '20261007 21:36:42'),
(1, 7, '40950967', '20261008 09:16:57'),
(1, 7, '33815115', '20261008 11:12:51'),
(1, 7, '52743665', '20261008 13:39:52'),
(1, 8, '40950967', '20261008 15:53:55'),
(1, 8, '69830097', '20261008 17:26:57'),
(1, 8, '58889548', '20261008 20:32:53'),
(3, 9, '33718954', '20261009 12:50:52'),
(3, 9, '78481085', '20261009 14:22:18'),
(3, 9, '40950967', '20261009 14:27:01'),
(2, 10, '52743665', '20261009 17:30:08'),
(3, 10, '61004739', '20261009 18:26:30'),
(1, 10, '31633837', '20261009 19:01:01'),
(1, 10, '43541247', '20261009 21:23:51'),
(1, 10, '57484484', '20261009 21:37:28'),
(1, 11, '40950967', '20261010 07:12:38'),
(3, 11, '13202177', '20261010 07:29:23'),
(1, 12, '34406620', '20261010 08:10:42'),
(1, 11, '41691947', '20261010 08:32:31'),
(3, 12, '34406620', '20261010 08:37:30'),
(1, 12, '33718954', '20261010 10:53:13'),
(1, 12, '61004739', '20261010 11:49:39'),
(3, 11, '61004739', '20261010 11:57:22'),
(1, 12, '69812467', '20261010 13:45:16'),
(1, 11, '61004739', '20261010 13:59:58'),
(3, 13, '58571567', '20261010 15:20:48'),
(1, 13, '53639945', '20261010 16:04:29'),
(1, 13, '41691947', '20261010 16:05:39'),
(1, 14, '43541247', '20261010 16:07:27'),
(1, 14, '40950967', '20261010 17:08:42'),
(1, 14, '76849210', '20261010 17:16:26'),
(3, 13, '76849210', '20261010 17:21:32'),
(1, 14, '33718954', '20261010 21:59:55'),
(1, 15, '52743665', '20261011 11:23:37'),
(1, 15, '78473414', '20261011 11:54:23'),
(1, 15, '41691947', '20261011 13:15:37'),
(3, 16, '57484484', '20261011 17:59:09'),
(1, 16, '53639945', '20261011 18:37:31'),
(1, 16, '33815115', '20261011 20:02:28'),
(1, 16, '52743665', '20261011 21:00:29'),
(1, 17, '57484484', '20261012 09:04:45'),
(1, 17, '41691947', '20261012 13:23:55'),
(3, 17, '57484484', '20261012 14:05:20'),
(3, 18, '41691947', '20261012 15:21:38'),
(1, 18, '31633837', '20261012 19:02:26'),
(1, 18, '33815115', '20261012 19:06:52'),
(1, 18, '57484484', '20261012 19:49:20'),
(2, 18, '43541247', '20261012 22:30:13'),
(3, 19, '65656198', '20261013 07:37:58'),
(1, 19, '33815115', '20261013 10:58:17'),
(1, 19, '41691947', '20261013 11:56:45'),
(3, 19, '41691947', '20261013 12:27:29'),
(1, 19, '52743665', '20261013 12:32:57'),
(1, 20, '41691947', '20261013 16:01:13'),
(1, 20, '61004739', '20261013 21:12:14'),
(1, 20, '53639945', '20261013 22:28:21'),
(1, 21, '33815115', '20261014 07:20:38'),
(1, 21, '33815115', '20261014 08:14:45'),
(1, 21, '61004739', '20261014 10:29:59'),
(1, 21, '32077262', '20261014 11:53:33'),
(1, 22, '76849210', '20261014 17:48:08'),
(1, 22, '61004739', '20261014 17:58:21'),
(1, 22, '71928958', '20261014 18:30:08'),
(1, 22, '40950967', '20261014 18:33:17'),
(1, 22, '71928958', '20261014 21:27:02'),
(3, 23, '52743665', '20261015 08:05:14'),
(1, 23, '66856101', '20261015 10:55:08'),
(2, 23, '32077262', '20261015 13:24:16'),
(1, 24, '33718954', '20261015 16:58:20'),
(1, 24, '58276962', '20261015 17:57:04'),
(1, 24, '41691947', '20261015 22:49:05'),
(1, 25, '41691947', '20261016 07:18:35'),
(3, 25, '71928958', '20261016 07:42:45'),
(1, 25, '71928958', '20261016 11:16:32'),
(3, 25, '78481085', '20261016 14:33:29'),
(1, 25, '61004739', '20261016 14:40:46'),
(1, 26, '13202177', '20261016 17:03:43'),
(2, 26, '71928958', '20261016 19:23:02'),
(1, 26, '53639945', '20261016 19:35:20'),
(1, 26, '47460468', '20261016 20:58:02'),
(3, 27, '43541247', '20261017 07:12:54'),
(3, 27, '52743665', '20261017 07:23:11'),
(1, 27, '61004739', '20261017 07:50:17'),
(1, 28, '47460468', '20261017 07:51:48'),
(1, 28, '69812467', '20261017 09:09:41'),
(1, 27, '33718954', '20261017 09:45:17'),
(2, 27, '57484484', '20261017 10:33:39'),
(1, 28, '34406620', '20261017 11:37:50'),
(1, 27, '69830097', '20261017 12:45:05'),
(3, 28, '33298688', '20261017 13:45:09'),
(1, 28, '41691947', '20261017 14:02:19'),
(1, 29, '34406620', '20261017 16:13:13'),
(1, 30, '34406620', '20261017 16:16:28'),
(1, 30, '76849210', '20261017 16:26:16'),
(1, 30, '33718954', '20261017 18:18:22'),
(1, 29, '71928958', '20261017 18:33:55'),
(3, 29, '61004739', '20261017 18:43:57'),
(2, 30, '53639945', '20261017 18:45:44'),
(2, 30, '52743665', '20261017 19:22:58'),
(2, 29, '33815115', '20261017 20:22:08'),
(1, 30, '76849210', '20261017 22:01:33'),
(1, 31, '41691947', '20261018 07:53:58'),
(1, 31, '33815115', '20261018 08:16:30'),
(1, 31, '71928958', '20261018 08:17:09'),
(1, 31, '76849210', '20261018 12:46:42'),
(1, 32, '71928958', '20261018 17:05:47'),
(3, 32, '40950967', '20261018 18:43:35'),
(1, 32, '43541247', '20261018 21:00:04'),
(1, 32, '69812467', '20261018 21:28:16'),
(3, 33, '76849210', '20261019 07:23:28'),
(3, 33, '40950967', '20261019 12:47:36'),
(2, 33, '57484484', '20261019 13:09:59'),
(1, 34, '71928958', '20261019 15:33:34'),
(1, 34, '33718954', '20261019 21:35:27'),
(2, 34, '75768555', '20261019 21:45:08'),
(3, 34, '69830097', '20261019 22:14:27'),
(2, 35, '71928958', '20261020 08:27:15'),
(3, 35, '40950967', '20261020 09:48:47'),
(1, 35, '40950967', '20261020 10:25:17'),
(3, 35, '31633837', '20261020 11:19:36'),
(1, 36, '43541247', '20261020 17:36:52'),
(1, 36, '69812467', '20261020 19:30:48'),
(1, 36, '78952666', '20261020 19:34:26'),
(3, 36, '33718954', '20261020 19:57:25'),
(1, 37, '47460468', '20261021 10:58:48'),
(1, 37, '52743665', '20261021 11:38:45'),
(1, 37, '52743665', '20261021 13:47:32'),
(1, 37, '33815115', '20261021 14:29:16'),
(1, 37, '61004739', '20261021 14:46:34'),
(1, 38, '63668769', '20261021 16:35:24'),
(1, 38, '61004739', '20261021 17:16:29'),
(1, 38, '57484484', '20261021 17:52:04'),
(3, 38, '71928958', '20261021 18:45:32'),
(3, 38, '43541247', '20261021 19:36:56'),
(3, 39, '78481085', '20261022 09:31:40'),
(1, 39, '76849210', '20261022 11:03:33'),
(3, 39, '78952666', '20261022 12:09:35'),
(1, 39, '69812467', '20261022 13:20:54'),
(1, 39, '40950967', '20261022 13:29:54'),
(2, 40, '41691947', '20261022 15:56:02'),
(3, 40, '61004739', '20261022 20:24:26'),
(1, 40, '78481085', '20261022 20:29:58'),
(3, 40, '33815115', '20261022 21:47:28'),
(3, 40, '61004739', '20261022 22:36:39'),
(1, 41, '32077262', '20261023 07:48:51'),
(3, 41, '69812467', '20261023 08:46:11'),
(2, 41, '40950967', '20261023 10:24:27'),
(1, 42, '43541247', '20261023 15:46:30'),
(3, 42, '52743665', '20261023 16:30:00'),
(1, 42, '52743665', '20261023 18:57:36'),
(1, 42, '58276962', '20261023 22:26:07'),
(1, 42, '32077262', '20261023 22:30:20'),
(1, 44, '57484484', '20261024 07:45:05'),
(1, 44, '57484484', '20261024 08:30:55'),
(3, 43, '33718954', '20261024 10:16:03'),
(2, 43, '61004739', '20261024 11:14:31');

-- INSERTAMOS DATOS EN LA TABLA DETALLE_VENTA

INSERT INTO DETALLE_VENTA (ID_VENTA, ID_PRODUCTO, CANTIDAD_VENTA, PRECIO_UNITARIO) VALUES
(1, 6, 4, 8.90),
(1, 7, 4, 7.50),
(1, 12, 1, 6.50),
(1, 13, 1, 3.20),
(2, 10, 1, 7.80),
(2, 14, 2, 7.50),
(2, 37, 2, 8.50),
(2, 39, 1, 3.00),
(2, 44, 2, 3.80),
(3, 13, 2, 3.20),
(3, 19, 2, 3.50),
(3, 38, 3, 3.50),
(3, 54, 1, 29.90),
(4, 1, 3, 4.80),
(4, 18, 2, 3.50),
(4, 36, 2, 6.00),
(5, 4, 2, 24.90),
(5, 8, 2, 5.20),
(5, 39, 1, 3.00),
(5, 41, 2, 3.50),
(5, 45, 1, 4.50),
(6, 3, 1, 5.50),
(6, 8, 1, 5.20),
(6, 55, 1, 39.90),
(7, 11, 1, 5.90),
(7, 20, 1, 6.00),
(8, 16, 1, 2.50),
(8, 34, 1, 11.50),
(8, 40, 1, 7.50),
(8, 44, 1, 3.80),
(9, 12, 2, 6.50),
(9, 17, 1, 2.20),
(9, 44, 2, 3.80),
(10, 32, 2, 14.90),
(10, 40, 1, 7.50),
(11, 9, 1, 4.20),
(11, 12, 1, 6.50),
(11, 18, 4, 3.50),
(11, 31, 1, 12.50),
(12, 18, 1, 3.50),
(13, 4, 1, 24.90),
(13, 13, 1, 3.20),
(13, 17, 2, 2.20),
(13, 32, 1, 14.90),
(13, 50, 1, 15.90),
(14, 14, 3, 7.50),
(14, 42, 1, 3.20),
(14, 44, 2, 3.80),
(15, 12, 1, 6.50),
(15, 30, 1, 5.90),
(15, 33, 1, 17.90),
(15, 38, 4, 3.50),
(15, 57, 1, 11.90),
(16, 2, 1, 3.90),
(16, 14, 3, 7.50),
(17, 15, 1, 1.80),
(17, 42, 2, 3.20),
(18, 6, 1, 8.90),
(18, 8, 1, 5.20),
(19, 13, 1, 3.20),
(19, 29, 2, 18.90),
(20, 5, 2, 9.50),
(20, 13, 2, 3.20),
(20, 21, 1, 6.50),
(20, 43, 4, 6.50),
(21, 22, 4, 8.90),
(21, 27, 3, 9.90),
(21, 28, 1, 4.50),
(21, 58, 1, 42.90),
(22, 7, 1, 7.50),
(22, 15, 2, 1.80),
(22, 18, 1, 3.50),
(22, 20, 1, 6.00),
(22, 36, 1, 6.00),
(23, 2, 2, 3.90),
(23, 3, 2, 5.50),
(23, 6, 1, 8.90),
(23, 19, 2, 3.50),
(24, 1, 2, 4.80),
(24, 15, 1, 1.80),
(25, 13, 3, 3.20),
(25, 15, 2, 1.80),
(25, 32, 2, 14.90),
(26, 5, 1, 9.50),
(26, 6, 1, 8.90),
(26, 7, 1, 7.50),
(26, 8, 1, 5.20),
(26, 14, 1, 7.50),
(27, 4, 2, 24.90),
(27, 23, 2, 3.50),
(28, 11, 2, 5.90),
(29, 6, 2, 8.90),
(29, 13, 4, 3.20),
(30, 37, 2, 8.50),
(30, 51, 2, 4.50),
(31, 3, 1, 5.50),
(31, 36, 1, 6.00),
(31, 52, 1, 7.50),
(32, 18, 1, 3.50),
(33, 6, 3, 8.90),
(33, 7, 4, 7.50),
(33, 18, 1, 3.50),
(33, 51, 6, 4.50),
(34, 7, 2, 7.50),
(34, 13, 3, 3.20),
(34, 30, 1, 5.90),
(35, 9, 1, 4.20),
(35, 46, 1, 13.90),
(36, 11, 1, 5.90),
(36, 39, 1, 3.00),
(37, 6, 1, 8.90),
(37, 7, 1, 7.50),
(37, 32, 2, 14.90),
(38, 7, 2, 7.50),
(38, 9, 3, 4.20),
(38, 13, 2, 3.20),
(38, 53, 1, 35.90),
(38, 55, 1, 39.90),
(39, 17, 1, 2.20),
(39, 33, 4, 17.90),
(40, 26, 1, 2.80),
(40, 45, 3, 4.50),
(41, 4, 2, 24.90),
(41, 24, 2, 14.90),
(41, 43, 2, 6.50),
(42, 2, 1, 3.90),
(42, 6, 2, 8.90),
(43, 2, 1, 3.90),
(43, 39, 1, 3.00),
(44, 4, 1, 24.90),
(44, 15, 2, 1.80),
(44, 33, 3, 17.90),
(45, 2, 2, 3.90),
(45, 19, 1, 3.50),
(46, 23, 1, 3.50),
(46, 38, 1, 3.50),
(46, 42, 1, 3.20),
(47, 1, 4, 4.80),
(47, 8, 2, 5.20),
(47, 15, 3, 1.80),
(47, 51, 2, 4.50),
(48, 10, 1, 7.80),
(49, 3, 1, 5.50),
(49, 36, 2, 6.00),
(50, 16, 2, 2.50),
(50, 20, 1, 6.00),
(50, 56, 1, 39.90),
(51, 5, 1, 9.50),
(51, 32, 1, 14.90),
(52, 11, 1, 5.90),
(52, 19, 1, 3.50),
(52, 20, 1, 6.00),
(53, 2, 4, 3.90),
(53, 13, 2, 3.20),
(53, 46, 2, 13.90),
(54, 20, 1, 6.00),
(54, 26, 4, 2.80),
(54, 28, 2, 4.50),
(54, 36, 1, 6.00),
(55, 5, 4, 9.50),
(55, 18, 1, 3.50),
(55, 28, 2, 4.50),
(55, 31, 2, 12.50),
(55, 55, 1, 39.90),
(56, 16, 4, 2.50),
(56, 20, 2, 6.00),
(56, 32, 1, 14.90),
(57, 2, 1, 3.90),
(57, 16, 1, 2.50),
(57, 33, 3, 17.90),
(57, 45, 1, 4.50),
(58, 3, 1, 5.50),
(58, 28, 3, 4.50),
(59, 20, 2, 6.00),
(60, 26, 1, 2.80),
(60, 31, 2, 12.50),
(60, 44, 1, 3.80),
(60, 56, 1, 39.90),
(61, 20, 1, 6.00),
(61, 25, 3, 4.50),
(62, 9, 3, 4.20),
(62, 10, 2, 7.80),
(62, 27, 1, 9.90),
(62, 36, 1, 6.00),
(63, 35, 3, 9.90),
(63, 50, 2, 15.90),
(64, 4, 2, 22.90),
(65, 44, 1, 3.80),
(66, 7, 1, 7.50),
(66, 18, 1, 3.50),
(66, 41, 1, 3.50),
(66, 44, 1, 3.80),
(66, 54, 1, 29.90),
(67, 5, 1, 9.50),
(67, 8, 1, 5.20),
(67, 16, 1, 2.50),
(67, 27, 1, 9.90),
(68, 32, 1, 14.90),
(68, 41, 3, 3.50),
(68, 43, 1, 6.50),
(69, 8, 2, 5.20),
(69, 14, 1, 6.90),
(69, 30, 1, 5.90),
(69, 37, 2, 8.50),
(69, 54, 1, 29.90),
(70, 3, 4, 5.50),
(70, 12, 1, 6.50),
(70, 19, 3, 3.50),
(70, 31, 3, 12.50),
(70, 34, 1, 11.50),
(71, 4, 2, 22.90),
(71, 22, 1, 8.90),
(71, 25, 1, 4.50),
(71, 50, 1, 15.90),
(72, 13, 1, 3.20),
(72, 14, 4, 6.90),
(72, 32, 2, 14.90),
(72, 50, 1, 15.90),
(73, 11, 3, 5.90),
(73, 23, 1, 3.50),
(74, 22, 1, 8.90),
(74, 30, 1, 5.90),
(74, 36, 1, 6.00),
(75, 14, 2, 6.90),
(75, 15, 2, 1.80),
(76, 6, 3, 8.90),
(76, 54, 1, 29.90),
(77, 1, 3, 4.80),
(77, 17, 1, 2.20),
(77, 35, 1, 9.90),
(78, 10, 1, 7.80),
(78, 11, 1, 5.90),
(79, 39, 1, 3.00),
(79, 43, 2, 6.50),
(79, 58, 1, 42.90),
(80, 1, 3, 4.80),
(81, 6, 1, 8.90),
(81, 19, 2, 3.50),
(81, 20, 2, 6.00),
(81, 31, 4, 12.50),
(82, 3, 1, 5.50),
(82, 6, 2, 8.90),
(82, 7, 2, 7.50),
(82, 41, 1, 3.50),
(83, 25, 3, 4.50),
(83, 37, 1, 8.50),
(83, 40, 1, 7.50),
(83, 45, 1, 4.50),
(83, 51, 4, 4.50),
(84, 3, 2, 5.50),
(84, 19, 3, 3.50),
(84, 24, 1, 14.90),
(84, 52, 2, 7.50),
(85, 1, 2, 4.80),
(85, 10, 1, 7.80),
(85, 36, 2, 6.00),
(86, 2, 1, 3.90),
(86, 3, 1, 5.50),
(86, 22, 1, 8.90),
(86, 39, 2, 3.00),
(86, 45, 2, 4.50),
(87, 3, 1, 5.50),
(87, 13, 2, 3.20),
(87, 42, 4, 3.20),
(88, 5, 1, 9.50),
(88, 32, 1, 14.90),
(89, 1, 1, 4.80),
(89, 8, 2, 5.20),
(89, 9, 1, 4.20),
(90, 2, 3, 3.90),
(90, 10, 2, 7.80),
(90, 41, 2, 3.50),
(91, 4, 2, 22.90),
(91, 32, 2, 14.90),
(92, 1, 1, 4.80),
(92, 15, 4, 1.80),
(93, 13, 1, 3.20),
(93, 36, 1, 6.00),
(93, 42, 2, 3.20),
(93, 56, 1, 39.90),
(93, 60, 3, 14.90),
(94, 3, 1, 5.50),
(94, 8, 1, 5.20),
(94, 32, 1, 14.90),
(94, 34, 1, 11.50),
(94, 53, 1, 35.90),
(95, 11, 1, 5.90),
(95, 19, 2, 3.50),
(96, 9, 1, 4.20),
(97, 2, 1, 3.90),
(97, 3, 1, 5.50),
(98, 51, 2, 4.50),
(99, 4, 1, 22.90),
(99, 24, 2, 14.90),
(99, 26, 2, 2.80),
(99, 39, 2, 3.00),
(100, 1, 1, 4.80),
(101, 31, 2, 12.50),
(101, 47, 1, 6.90),
(101, 55, 1, 39.90),
(102, 8, 3, 5.20),
(102, 18, 3, 3.50),
(103, 10, 1, 7.80),
(103, 31, 1, 12.50),
(103, 49, 2, 12.50),
(104, 36, 1, 6.00),
(104, 39, 2, 3.00),
(104, 44, 3, 3.80),
(104, 51, 2, 4.50),
(105, 13, 1, 3.20),
(105, 18, 2, 3.50),
(105, 54, 1, 29.90),
(106, 26, 1, 2.80),
(107, 2, 1, 3.90),
(107, 39, 3, 3.00),
(107, 53, 1, 35.90),
(108, 33, 1, 17.90),
(108, 38, 1, 3.50),
(108, 59, 1, 9.50),
(109, 19, 2, 3.50),
(109, 37, 1, 8.50),
(109, 41, 1, 3.50),
(109, 51, 6, 4.50),
(110, 25, 1, 4.50),
(110, 28, 3, 4.50),
(110, 36, 2, 6.00),
(111, 41, 1, 3.50),
(112, 6, 1, 8.90),
(112, 30, 1, 5.90),
(112, 53, 1, 35.90),
(113, 37, 1, 8.50),
(114, 7, 1, 7.50),
(115, 12, 1, 6.50),
(115, 40, 2, 7.50),
(115, 53, 1, 35.90),
(116, 1, 1, 4.80),
(116, 18, 4, 3.50),
(116, 20, 2, 6.00),
(116, 29, 1, 18.90),
(116, 52, 1, 7.50),
(117, 8, 2, 5.20),
(117, 39, 1, 3.00),
(118, 13, 3, 3.20),
(118, 14, 1, 6.90),
(118, 42, 2, 3.20),
(119, 14, 3, 6.90),
(119, 21, 2, 6.50),
(120, 15, 1, 1.80),
(120, 21, 2, 6.50),
(120, 27, 2, 9.90),
(120, 45, 1, 4.50),
(120, 58, 1, 42.90),
(121, 18, 1, 3.50),
(122, 1, 1, 4.80),
(122, 17, 1, 2.20),
(122, 32, 1, 14.90),
(123, 13, 1, 3.20),
(123, 34, 1, 11.50),
(124, 5, 1, 9.50),
(124, 8, 3, 5.20),
(124, 16, 3, 2.50),
(125, 11, 2, 5.90),
(125, 18, 1, 3.50),
(125, 19, 1, 3.50),
(126, 19, 3, 3.50),
(126, 47, 1, 6.90),
(127, 4, 3, 22.90),
(127, 16, 3, 2.50),
(127, 53, 1, 35.90),
(128, 4, 1, 22.90),
(128, 10, 1, 7.80),
(128, 18, 1, 3.50),
(129, 6, 1, 8.90),
(129, 11, 3, 5.90),
(129, 20, 2, 6.00),
(130, 14, 1, 6.90),
(130, 18, 3, 3.50),
(130, 45, 2, 4.50),
(131, 9, 1, 4.20),
(131, 11, 2, 5.90),
(131, 13, 2, 3.20),
(131, 25, 4, 4.50),
(131, 26, 2, 2.80),
(132, 1, 2, 4.80),
(132, 3, 1, 5.50),
(132, 23, 1, 3.50),
(132, 59, 2, 9.50),
(133, 21, 2, 6.50),
(134, 5, 1, 9.50),
(134, 9, 1, 4.20),
(134, 10, 1, 7.80),
(134, 45, 1, 4.50),
(135, 3, 1, 5.50),
(135, 32, 3, 14.90),
(135, 43, 1, 6.50),
(136, 11, 1, 5.90),
(136, 27, 2, 9.90),
(136, 31, 1, 12.50),
(137, 12, 2, 6.50),
(137, 17, 1, 2.20),
(137, 33, 1, 17.90),
(137, 34, 1, 11.50),
(138, 15, 4, 1.80),
(138, 16, 3, 2.50),
(138, 35, 4, 9.90),
(139, 15, 3, 1.80),
(139, 37, 2, 8.50),
(139, 57, 2, 11.90),
(140, 17, 1, 2.20),
(140, 22, 3, 8.90),
(140, 37, 1, 8.50),
(140, 48, 1, 16.90),
(141, 15, 1, 1.80),
(141, 39, 1, 3.00),
(142, 5, 2, 9.50),
(142, 8, 1, 5.20),
(143, 2, 2, 3.90),
(143, 13, 1, 3.20),
(143, 22, 2, 8.90),
(143, 38, 4, 3.50),
(144, 2, 2, 3.90),
(144, 21, 1, 6.50),
(144, 35, 1, 9.90),
(145, 15, 1, 1.80),
(145, 30, 1, 5.90),
(146, 6, 1, 8.90),
(146, 19, 1, 3.50),
(146, 40, 1, 7.50),
(147, 1, 1, 4.80),
(147, 3, 1, 5.50),
(147, 12, 1, 6.50),
(147, 41, 2, 3.50),
(147, 42, 1, 3.20),
(148, 5, 1, 9.50),
(148, 6, 2, 8.90),
(148, 11, 4, 5.90),
(149, 14, 1, 7.50),
(150, 10, 2, 7.80),
(150, 26, 2, 2.80),
(150, 36, 1, 6.00),
(150, 38, 3, 3.50),
(151, 1, 1, 4.80),
(151, 19, 1, 3.50),
(152, 27, 1, 9.90),
(152, 36, 3, 6.00),
(152, 58, 1, 42.90),
(153, 13, 4, 3.20),
(153, 14, 1, 7.50),
(153, 31, 1, 12.50),
(153, 57, 1, 11.90),
(154, 5, 3, 9.50),
(154, 6, 3, 8.90),
(154, 16, 3, 2.50),
(154, 42, 1, 3.20),
(155, 5, 3, 9.50),
(155, 36, 1, 6.00),
(156, 10, 1, 7.80),
(156, 31, 2, 12.50),
(156, 50, 2, 15.90),
(157, 3, 1, 5.50),
(157, 12, 1, 6.50),
(157, 19, 1, 3.50),
(157, 53, 1, 35.90),
(158, 1, 1, 4.80),
(158, 30, 1, 5.90),
(158, 54, 1, 29.90),
(159, 1, 1, 4.80),
(159, 41, 1, 3.50),
(159, 44, 1, 3.80),
(160, 36, 1, 6.00),
(160, 42, 1, 3.20),
(161, 33, 1, 17.90),
(161, 40, 3, 7.50),
(161, 45, 1, 4.50),
(162, 11, 2, 5.90),
(162, 12, 4, 6.50),
(162, 34, 3, 11.50),
(162, 40, 1, 7.50),
(162, 44, 3, 3.80),
(163, 2, 1, 3.90),
(163, 16, 2, 2.50),
(163, 31, 2, 12.50),
(163, 58, 1, 42.90),
(164, 13, 2, 3.20),
(164, 15, 2, 1.80),
(165, 24, 2, 14.90),
(165, 34, 2, 11.50),
(165, 42, 1, 3.20),
(166, 14, 1, 7.50),
(166, 17, 1, 2.20),
(166, 37, 1, 8.50),
(167, 40, 3, 7.50),
(167, 44, 1, 3.80),
(168, 6, 4, 8.90),
(168, 18, 1, 3.50),
(168, 54, 1, 29.90),
(169, 20, 1, 5.00),
(169, 28, 1, 4.50),
(169, 54, 1, 29.90),
(170, 5, 1, 9.50),
(170, 43, 2, 6.50),
(171, 3, 1, 5.50),
(171, 38, 1, 3.50),
(171, 54, 1, 29.90),
(172, 6, 1, 8.90),
(172, 20, 1, 5.00),
(172, 24, 3, 14.90),
(172, 28, 2, 4.50),
(173, 8, 2, 5.20),
(173, 15, 1, 1.80),
(173, 21, 2, 6.50),
(173, 25, 1, 4.50),
(174, 4, 4, 24.90),
(174, 5, 1, 9.50),
(174, 19, 2, 3.50),
(175, 8, 2, 5.20),
(175, 17, 2, 2.20),
(175, 54, 1, 29.90),
(176, 13, 1, 3.20),
(177, 12, 3, 6.50),
(177, 38, 2, 3.50);

-- INSERTAMOS DATOS EN LA TABLA DETALLE_METODO_PAGO

INSERT INTO DETALLE_METODO_PAGO (ID_VENTA, ID_PAGO, MONTO_PAGO, FECHA_PAGO) VALUES
(1, 1, 75.30,  '20261005 08:28:33'),
(2, 1, 23.28,  '20261005 10:09:06'),
(2, 3, 27.12,  '20261005 10:09:06'),
(3, 4, 53.80,  '20261005 10:16:15'),
(4, 1, 33.40,  '20261005 11:51:09'),
(5, 4, 74.70,  '20261005 17:32:59'),
(6, 4, 50.60,  '20261005 18:59:14'),
(7, 5, 11.90,  '20261005 20:40:59'),
(8, 1, 17.38,  '20261005 21:06:47'),
(8, 2, 7.92,   '20261005 21:06:47'),
(9, 2, 22.80,  '20261006 08:26:46'),
(10, 3, 17.01, '20261006 12:14:42'),
(10, 4, 20.29, '20261006 12:14:42'),
(11, 3, 37.20, '20261006 13:32:00'),
(12, 1, 3.50,  '20261006 15:28:19'),
(13, 3, 63.30, '20261006 15:41:00'),
(14, 2, 33.30, '20261006 16:21:55'),
(15, 4, 56.20, '20261006 16:38:01'),
(16, 3, 26.40, '20261006 17:28:09'),
(17, 1, 8.20,  '20261007 08:02:21'),
(18, 1, 14.10, '20261007 11:17:36'),
(19, 1, 41.00, '20261007 12:56:50'),
(20, 1, 57.90, '20261007 15:27:08'),
(21, 1, 58.49, '20261007 19:47:34'),
(21, 4, 54.21, '20261007 19:47:34'),
(22, 2, 26.60, '20261007 21:36:42'),
(23, 1, 34.70, '20261008 09:16:57'),
(24, 4, 11.40, '20261008 11:12:51'),
(25, 4, 43.00, '20261008 13:39:52'),
(26, 4, 38.60, '20261008 15:53:55'),
(27, 1, 56.80, '20261008 17:26:57'),
(28, 4, 11.80, '20261008 20:32:53'),
(29, 1, 30.60, '20261009 12:50:52'),
(30, 1, 26.00, '20261009 14:22:18'),
(31, 4, 19.00, '20261009 14:27:01'),
(32, 5, 3.50,  '20261009 17:30:08'),
(33, 1, 87.20, '20261009 18:26:30'),
(34, 4, 30.50, '20261009 19:01:01'),
(35, 3, 18.10, '20261009 21:23:51'),
(36, 1, 8.90,  '20261009 21:37:28'),
(37, 2, 46.20, '20261010 07:12:38'),
(38, 1, 109.80,'20261010 07:29:23'),
(39, 1, 73.80, '20261010 08:10:42'),
(40, 4, 16.30, '20261010 08:32:31'),
(41, 1, 29.35, '20261010 08:37:30'),
(41, 2, 63.25, '20261010 08:37:30'),
(42, 4, 21.70, '20261010 10:53:13'),
(43, 1, 6.90,  '20261010 11:49:39'),
(44, 1, 82.20, '20261010 11:57:22'),
(45, 2, 11.30, '20261010 13:45:16'),
(46, 4, 10.20, '20261010 13:59:58'),
(47, 1, 44.00, '20261010 15:20:48'),
(48, 1, 7.80,  '20261010 16:04:29'),
(49, 1, 17.50, '20261010 16:05:39'),
(50, 1, 50.90, '20261010 16:07:27'),
(51, 5, 24.40, '20261010 17:08:42'),
(52, 5, 15.40, '20261010 17:16:26'),
(53, 4, 49.80, '20261010 17:21:32'),
(54, 4, 32.20, '20261010 21:59:55'),
(55, 1, 115.40,'20261011 11:23:37'),
(56, 2, 36.90, '20261011 11:54:23'),
(57, 4, 64.60, '20261011 13:15:37'),
(58, 1, 19.00, '20261011 17:59:09'),
(59, 1, 12.00, '20261011 18:37:31'),
(60, 3, 71.50, '20261011 20:02:28'),
(61, 2, 19.50, '20261011 21:00:29'),
(62, 1, 44.10, '20261012 09:04:45'),
(63, 3, 61.50, '20261012 13:23:55'),
(64, 1, 45.80, '20261012 14:05:20'),
(65, 4, 3.80,  '20261012 15:21:38'),
(66, 4, 48.20, '20261012 19:02:26'),
(67, 3, 27.10, '20261012 19:06:52'),
(68, 1, 16.01, '20261012 19:49:20'),
(68, 4, 15.89, '20261012 19:49:20'),
(69, 3, 70.10, '20261012 22:30:13'),
(70, 3, 88.00, '20261013 07:37:58'),
(71, 1, 75.10, '20261013 10:58:17'),
(72, 4, 76.50, '20261013 11:56:45'),
(73, 3, 21.20, '20261013 12:27:29'),
(74, 4, 20.80, '20261013 12:32:57'),
(75, 1, 17.40, '20261013 16:01:13'),
(76, 1, 56.60, '20261013 21:12:14'),
(77, 3, 26.50, '20261013 22:28:21'),
(78, 3, 13.70, '20261014 07:20:38'),
(79, 4, 58.90, '20261014 08:14:45'),
(80, 3, 14.40, '20261014 10:29:59'),
(81, 1, 77.90, '20261014 11:53:33'),
(82, 1, 14.25, '20261014 17:48:08'),
(82, 3, 27.55, '20261014 17:48:08'),
(83, 1, 52.00, '20261014 17:58:21'),
(84, 1, 20.71, '20261014 18:30:08'),
(84, 3, 30.69, '20261014 18:30:08'),
(85, 4, 29.40, '20261014 18:33:17'),
(86, 4, 33.30, '20261014 21:27:02'),
(87, 3, 24.70, '20261015 08:05:14'),
(88, 1, 24.40, '20261015 10:55:08'),
(89, 3, 19.40, '20261015 13:24:16'),
(90, 1, 34.30, '20261015 16:58:20'),
(91, 2, 75.60, '20261015 17:57:04'),
(92, 1, 12.00, '20261015 22:49:05'),
(93, 1, 100.20, '20261016 07:18:35'),
(94, 4, 73.00, '20261016 07:42:45'),
(95, 2, 12.90, '20261016 11:16:32'),
(96, 1, 4.20, '20261016 14:33:29'),
(97, 2, 9.40, '20261016 14:40:46'),
(98, 1, 9.00, '20261016 17:03:43'),
(99, 1, 64.30, '20261016 19:23:02'),
(100, 4, 4.80, '20261016 19:35:20'),
(101, 3, 71.80, '20261016 20:58:02'),
(102, 2, 26.10, '20261017 07:12:54'),
(103, 1, 45.30, '20261017 07:23:11'),
(104, 3, 32.40, '20261017 07:50:17'),
(105, 5, 40.10, '20261017 07:51:48'),
(106, 3, 2.80, '20261017 09:09:41'),
(107, 4, 48.80, '20261017 09:45:17'),
(108, 4, 30.90, '20261017 10:33:39'),
(109, 4, 46.00, '20261017 11:37:50'),
(110, 3, 30.00, '20261017 12:45:05'),
(111, 3, 3.50, '20261017 13:45:09'),
(112, 3, 50.70, '20261017 14:02:19'),
(113, 1, 8.50, '20261017 16:13:13'),
(114, 1, 7.50, '20261017 16:16:28'),
(115, 1, 57.40, '20261017 16:26:16'),
(116, 2, 23.91, '20261017 18:18:22'),
(116, 5, 33.29, '20261017 18:18:22'),
(117, 1, 13.40, '20261017 18:33:55'),
(118, 1, 22.90, '20261017 18:43:57'),
(119, 5, 33.70, '20261017 18:45:44'),
(120, 4, 82.00, '20261017 19:22:58'),
(121, 5, 3.50, '20261017 20:22:08'),
(122, 1, 21.90, '20261017 22:01:33'),
(123, 1, 14.70, '20261018 07:53:58'),
(124, 1, 32.60, '20261018 08:16:30'),
(125, 4, 18.80, '20261018 08:17:09'),
(126, 4, 17.40, '20261018 12:46:42'),
(127, 1, 112.10, '20261018 17:05:47'),
(128, 1, 34.20, '20261018 18:43:35'),
(129, 1, 38.60, '20261018 21:00:04'),
(130, 1, 26.40, '20261018 21:28:16'),
(131, 1, 46.00, '20261019 07:23:28'),
(132, 1, 37.60, '20261019 12:47:36'),
(133, 2, 13.00, '20261019 13:09:59'),
(134, 2, 9.83, '20261019 15:33:34'),
(134, 3, 16.17, '20261019 15:33:34'),
(135, 1, 56.70, '20261019 21:35:27'),
(136, 4, 38.20, '20261019 21:45:08'),
(137, 4, 44.60, '20261019 22:14:27'),
(138, 2, 26.39, '20261020 08:27:15'),
(138, 3, 27.91, '20261020 08:27:15'),
(139, 4, 46.20, '20261020 09:48:47'),
(140, 1, 54.30, '20261020 10:25:17'),
(141, 1, 4.80, '20261020 11:19:36'),
(142, 1, 24.20, '20261020 17:36:52'),
(143, 1, 42.80, '20261020 19:30:48'),
(144, 4, 24.20, '20261020 19:34:26'),
(145, 3, 7.70, '20261020 19:57:25'),
(146, 1, 19.90, '20261021 10:58:48'),
(147, 2, 27.00, '20261021 11:38:45'),
(148, 1, 50.90, '20261021 13:47:32'),
(149, 4, 7.50, '20261021 14:29:16'),
(150, 3, 12.52, '20261021 14:46:34'),
(150, 4, 25.18, '20261021 14:46:34'),
(151, 1, 8.30, '20261021 16:35:24'),
(152, 5, 70.80, '20261021 17:16:29'),
(153, 1, 44.70, '20261021 17:52:04'),
(154, 1, 65.90, '20261021 18:45:32'),
(155, 5, 34.50, '20261021 19:36:56'),
(156, 3, 64.60, '20261022 09:31:40'),
(157, 1, 51.40, '20261022 11:03:33'),
(158, 1, 40.60, '20261022 12:09:35'),
(159, 4, 12.10, '20261022 13:20:54'),
(160, 4, 9.20, '20261022 13:29:54'),
(161, 4, 44.90, '20261022 15:56:02'),
(162, 4, 91.20, '20261022 20:24:26'),
(163, 2, 76.80, '20261022 20:29:58'),
(164, 4, 10.00, '20261022 21:47:28'),
(165, 1, 56.00, '20261022 22:36:39'),
(166, 1, 18.20, '20261023 07:48:51'),
(167, 3, 26.30, '20261023 08:46:11'),
(168, 4, 69.00, '20261023 10:24:27'),
(169, 1, 39.40, '20261023 15:46:30'),
(170, 1, 22.50, '20261023 16:30:00'),
(171, 1, 38.90, '20261023 18:57:36'),
(172, 1, 25.62, '20261023 22:26:07'),
(172, 2, 41.98, '20261023 22:26:07'),
(173, 3, 29.70, '20261023 22:30:20'),
(174, 5, 116.10, '20261024 07:45:05'),
(175, 4, 44.70, '20261024 08:30:55'),
(176, 4, 3.20, '20261024 10:16:03'),
(177, 1, 26.50, '20261024 11:14:31');

-- INSERTAMOS DATOS EN LA TABLA MOVIMIENTO_INVENTARIO (Entradas = Compras, Salidas = Ventas)
INSERT INTO MOVIMIENTO_INVENTARIO (ID_PRODUCTO, CANTIDAD_MOVIMIENTO, FECHA_MOVIMIENTO, TIPO_MOVIMIENTO)
SELECT ID_PRODUCTO, CANTIDAD, FECHA, TIPO
FROM (
    SELECT DC.ID_PRODUCTO, DC.CANTIDAD_COMPRADA AS CANTIDAD, C.FECHA_COMPRA AS FECHA, 'E' AS TIPO
    FROM DETALLE_COMPRA DC INNER JOIN COMPRA C ON C.ID_COMPRA = DC.ID_COMPRA
    UNION ALL
    SELECT DV.ID_PRODUCTO, DV.CANTIDAD_VENTA, V.FECHA_VENTA, 'S'
    FROM DETALLE_VENTA DV INNER JOIN VENTA V ON V.ID_VENTA = DV.ID_VENTA
) X
ORDER BY FECHA, TIPO;

-- REALIZAMOS CONSULTAS EN NUESTRO PROYECTO

-- CONSULTAS

-- 1). ¿Quienes son los empleados de Mi Barrio Market?
SELECT * FROM EMPLEADO;
-- 2). ¿Cúales son todas las categorias en las que se puede categorizar un producto?
SELECT * FROM CATEGORIA;

-- 3). ¿Qué productos cuestan más de 20 soles?
SELECT NOMBRE_PRODUCTO AS PRODUCTO,
       PRECIO_VENTA AS PRECIO
FROM PRODUCTO 
WHERE (PRECIO_VENTA > 20)

-- SUBCONSULTAS MONO REGISTRO 

-- 1). ¿Qué productos cuestan más que el precio promedio de todos los productos?
SELECT NOMBRE_PRODUCTO AS PRODUCTO,
       PRECIO_VENTA AS PRECIO
FROM PRODUCTO
WHERE PRECIO_VENTA > (SELECT AVG (PRECIO_VENTA) FROM PRODUCTO);

-- 2). ¿Cuál es el producto más caro de la tienda?
SELECT NOMBRE_PRODUCTO AS PRODUCTO,
       PRECIO_VENTA AS PRECIO
FROM PRODUCTO
WHERE PRECIO_VENTA = (SELECT MAX (PRECIO_VENTA) FROM PRODUCTO);

-- 3). ¿Qué empleados ganan más que Rosa Elena Castillo Paredes?
SELECT NOMBRE_EMPLEADO,  
       APELLIDO_EMPLEADO,
       SUELDO_BASE AS SUELDO
FROM EMPLEADO
WHERE SUELDO_BASE > (SELECT SUELDO_BASE FROM EMPLEADO
                     WHERE NOMBRE_EMPLEADO = N'Rosa Elena' AND APELLIDO_EMPLEADO = N'Castillo Paredes')

-- SUBCONSULTAS MULTI REGISTRO 

-- 1). ¿Qué productos pertenecen a las categorías Lácteos o Bebidas? (IN)
SELECT NOMBRE_PRODUCTO AS PRODUCTO, 
       PRECIO_VENTA AS PRECIO
FROM PRODUCTO
WHERE ID_CATEGORIA IN (SELECT ID_CATEGORIA FROM CATEGORIA
                       WHERE NOMBRE_CATEGORIA = N'Lácteos' OR NOMBRE_CATEGORIA = N'Bebidas')

-- 2). ¿Qué productos nunca se han vendido? (NOT IN)
SELECT NOMBRE_PRODUCTO AS PRODUCTO
FROM PRODUCTO
WHERE ID_PRODUCTO NOT IN (SELECT ID_PRODUCTO FROM DETALLE_VENTA);

-- 3). ¿Qué productos cuestan más que TODOS los productos de la categoría Lácteos? (ALL)
SELECT NOMBRE_PRODUCTO AS PRODUCTO, 
       PRECIO_VENTA AS PRECIO
FROM PRODUCTO
WHERE PRECIO_VENTA > ALL (SELECT PRECIO_VENTA
                          FROM PRODUCTO
                          WHERE ID_CATEGORIA = (SELECT ID_CATEGORIA
                                                FROM CATEGORIA
                                                WHERE NOMBRE_CATEGORIA = N'Lácteos'));

-- SUBCONSULTAS MULTI COLUMNA 

-- 1). ¿Cuál es el producto más caro de cada categoría?
SELECT P.NOMBRE_PRODUCTO AS PRODUCTO, 
       P.ID_CATEGORIA, 
       P.PRECIO_VENTA AS PRECIO
FROM PRODUCTO P
WHERE EXISTS (SELECT 1
              FROM (SELECT ID_CATEGORIA, 
                           MAX(PRECIO_VENTA) AS PRECIO_MAXIMO
                    FROM PRODUCTO
                    GROUP BY ID_CATEGORIA) X
              WHERE X.ID_CATEGORIA = P.ID_CATEGORIA
                AND X.PRECIO_MAXIMO = P.PRECIO_VENTA);

-- 2). ¿Cuál es el producto más barato de cada categoría?
SELECT P.NOMBRE_PRODUCTO AS PRODUCTO, 
       P.ID_CATEGORIA, 
       P.PRECIO_VENTA AS PRECIO
FROM PRODUCTO P
WHERE EXISTS (SELECT 1
              FROM (SELECT ID_CATEGORIA, MIN(PRECIO_VENTA) AS PRECIO_MINIMO
                    FROM PRODUCTO
                    GROUP BY ID_CATEGORIA) X
              WHERE X.ID_CATEGORIA = P.ID_CATEGORIA
                AND X.PRECIO_MINIMO = P.PRECIO_VENTA);

-- 3). ¿Cuál fue la última compra de cada cliente?
SELECT V.ID_VENTA, 
       V.DNI, 
       V.FECHA_VENTA
FROM VENTA V
WHERE EXISTS (SELECT 1
              FROM (SELECT DNI, MAX(FECHA_VENTA) AS ULTIMA_VENTA
                    FROM VENTA
                    GROUP BY DNI) X
              WHERE X.DNI = V.DNI
                AND X.ULTIMA_VENTA = V.FECHA_VENTA);

-- CONSULTAS COMBINADAS: INNER JOIN

-- 1). ¿Cada producto a qué categoría pertenece?
SELECT P.NOMBRE_PRODUCTO AS PRODUCTO, 
       C.NOMBRE_CATEGORIA AS CATEGORIA, 
       P.PRECIO_VENTA AS PRECIO
FROM PRODUCTO P
INNER JOIN CATEGORIA C ON P.ID_CATEGORIA = C.ID_CATEGORIA;

-- 2). ¿Qué productos pertenecen a la categoría Bebidas?
SELECT P.NOMBRE_PRODUCTO AS PRODUCTO, 
       P.PRECIO_VENTA AS PRECIO
FROM PRODUCTO P
INNER JOIN CATEGORIA C ON P.ID_CATEGORIA = C.ID_CATEGORIA
WHERE C.NOMBRE_CATEGORIA = N'Bebidas';

-- 3). ¿Qué cajeros tiene la tienda y en qué turno trabajan?
SELECT E.NOMBRE_EMPLEADO, 
       E.APELLIDO_EMPLEADO,
       CJ.TURNO
FROM CAJERO CJ
INNER JOIN EMPLEADO E ON CJ.ID_EMPLEADO = E.ID_EMPLEADO;

-- 4). ¿A qué cliente se hizo cada venta y con qué tipo de comprobante?
SELECT V.ID_VENTA, 
       CL.NOMBRE_CLIENTE, 
       CL.APELLIDO_CLIENTE, 
       CO.TIPO_COMPROBANTE, 
       V.FECHA_VENTA
FROM VENTA V
INNER JOIN CLIENTE CL ON V.DNI = CL.DNI
INNER JOIN COMPROBANTE CO ON V.ID_COMPROBANTE = CO.ID_COMPROBANTE;

-- 5). ¿Qué productos se vendieron en cada venta y cuál fue el subtotal?
SELECT DV.ID_VENTA, 
       P.NOMBRE_PRODUCTO AS PRODUCTO, 
       DV.CANTIDAD_VENTA AS CANTIDAD, 
       DV.PRECIO_UNITARIO,
       DV.CANTIDAD_VENTA * DV.PRECIO_UNITARIO AS SUBTOTAL
FROM DETALLE_VENTA DV
INNER JOIN PRODUCTO P ON DV.ID_PRODUCTO = P.ID_PRODUCTO
ORDER BY DV.ID_VENTA;

-- 6). ¿Qué proveedor surtió cada compra y qué empleado la registró?
SELECT CP.ID_COMPRA, 
       PV.NOMBRE_PROVEEDOR AS PROVEEDOR, 
       E.NOMBRE_EMPLEADO AS REGISTRADO_POR,
       CP.FECHA_COMPRA
FROM COMPRA CP
INNER JOIN PROVEEDOR PV ON CP.RUC = PV.RUC
INNER JOIN EMPLEADO E ON CP.ID_EMPLEADO = E.ID_EMPLEADO;

-- 7). ¿Cuánto se ha vendido en total por cada categoría?
SELECT C.NOMBRE_CATEGORIA AS CATEGORIA, 
       SUM(DV.CANTIDAD_VENTA * DV.PRECIO_UNITARIO) AS TOTAL_VENDIDO
FROM CATEGORIA C
INNER JOIN PRODUCTO P ON C.ID_CATEGORIA = P.ID_CATEGORIA
INNER JOIN DETALLE_VENTA DV ON P.ID_PRODUCTO = DV.ID_PRODUCTO
GROUP BY C.NOMBRE_CATEGORIA
ORDER BY TOTAL_VENDIDO DESC;

-- FUNCIONES DE COLUMNA (COUNT, SUM, AVG, MAX, MIN)

-- 1). COUNT: ¿Cuántos empleados tiene la tienda?
SELECT COUNT(*) AS TOTAL_EMPLEADOS 
FROM EMPLEADO;

-- 2). SUM: ¿Cuánto paga la tienda en sueldos base al mes?
SELECT SUM(SUELDO_BASE) AS TOTAL_SUELDOS 
FROM EMPLEADO;

-- 3). AVG: ¿Cuál es el precio promedio de los productos?
SELECT ROUND(AVG(PRECIO_VENTA), 2) AS PRECIO_PROMEDIO 
FROM PRODUCTO;

-- 4). MAX y MIN: ¿Cuál es el precio más alto y el más bajo?
SELECT MAX(PRECIO_VENTA) AS PRECIO_MAXIMO, 
MIN(PRECIO_VENTA) AS PRECIO_MINIMO
FROM PRODUCTO;

-- 5). COUNT con GROUP BY: ¿Cuántos productos hay por categoría?
SELECT ID_CATEGORIA, COUNT(*) AS TOTAL_PRODUCTOS
FROM PRODUCTO
GROUP BY ID_CATEGORIA;

-- 6). SUM: ¿Cuánto dinero se ha vendido en total?
SELECT SUM(CANTIDAD_VENTA * PRECIO_UNITARIO) AS TOTAL_VENTAS FROM DETALLE_VENTA;

-- FUNCIONES DE FECHA

-- 1). GETDATE: ¿Cuál es la fecha y hora actual?
SELECT GETDATE() AS FECHA_HORA_ACTUAL;

-- 2). YEAR, MONTH y DAY: ¿En qué año, mes y día fue contratado cada empleado?
SELECT NOMBRE_EMPLEADO,
       APELLIDO_EMPLEADO,
YEAR(FECHA_CONTRATO) AS AÑO, 
MONTH(FECHA_CONTRATO) AS MES,
DAY(FECHA_CONTRATO) AS DIA
FROM EMPLEADO;

-- 3). DATEDIFF: ¿Cuántos años de antigüedad tiene cada empleado?
SELECT NOMBRE_EMPLEADO AS NOMBRE,
       APELLIDO_EMPLEADO AS APELLIDO,
       DATEDIFF(YEAR, FECHA_CONTRATO, GETDATE()) AS AÑOS_ANTIGUEDAD
FROM EMPLEADO;

-- 4). DATEADD: ¿Cuándo termina el periodo de prueba (3 meses) de cada empleado?
SELECT NOMBRE_EMPLEADO AS NOMBRE,
       APELLIDO_EMPLEADO AS APELLIDO, 
       FECHA_CONTRATO, DATEADD(MONTH, 3, FECHA_CONTRATO) AS FIN_PERIODO_PRUEBA
FROM EMPLEADO;

-- 5). YEAR, MONTH y COUNT: ¿Cuántas ventas se realizaron en octubre de 2026?
SELECT COUNT(*) AS VENTAS_OCTUBRE_2026
FROM VENTA
WHERE YEAR(FECHA_VENTA) = 2026 AND MONTH(FECHA_VENTA) = 10;

-- 6). FORMAT: ¿Cómo se ven las fechas de venta en formato dd/MM/yyyy HH:mm?
SELECT ID_VENTA, FORMAT(FECHA_VENTA, 'dd/MM/yyyy HH:mm') AS FECHA
FROM VENTA;

-- 7). DATEDIFF: ¿Qué clientes se registraron hace más de 30 días?
SELECT NOMBRE_CLIENTE, 
       APELLIDO_CLIENTE, 
       FECHA_REGISTRO,
       DATEDIFF(DAY, FECHA_REGISTRO, GETDATE()) AS DIAS_REGISTRADO
FROM CLIENTE
WHERE DATEDIFF(DAY, FECHA_REGISTRO, GETDATE()) > 30;

-- SENTENCIAS DCL (Data Control Language)

-- A) LOGIN

-- USAMOS MASTER PARA CREAR NUESTROS LOGIN
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'Moderador')
    CREATE LOGIN Moderador          WITH PASSWORD = 'Barrio#Market2026a',   CHECK_POLICY = ON;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'usr_admin')
    CREATE LOGIN Admininistrador    WITH PASSWORD = 'Tienda#Segura2026b',   CHECK_POLICY = ON;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'usr_cajero')
    CREATE LOGIN Cajero             WITH PASSWORD = 'Ventas#Diarias2026c',  CHECK_POLICY = ON;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'usr_reponedor')
    CREATE LOGIN Reponedor          WITH PASSWORD = 'Almacen#Orden2026d',   CHECK_POLICY = ON;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'usr_auditor')
    CREATE LOGIN Auditor            WITH PASSWORD = 'Revisar#Cuentas2026e', CHECK_POLICY = ON;
GO

-- REGRESAMOS A NUESTRA BASE DE DATOS
USE BASE_DATOS_MI_BARRIO_MARKET;
GO

-- B) USUARIOS (nivel base de datos): vinculan un login con ESTA base.

IF DATABASE_PRINCIPAL_ID('Moderador')       IS NULL CREATE USER Moderador     FOR LOGIN Moderador;
IF DATABASE_PRINCIPAL_ID('Administrador')   IS NULL CREATE USER usr_admin     FOR LOGIN usr_admin;
IF DATABASE_PRINCIPAL_ID('Cajero')          IS NULL CREATE USER usr_cajero    FOR LOGIN usr_cajero;
IF DATABASE_PRINCIPAL_ID('Reponedor')       IS NULL CREATE USER usr_reponedor FOR LOGIN usr_reponedor;
IF DATABASE_PRINCIPAL_ID('Auditor')         IS NULL CREATE USER usr_auditor   FOR LOGIN usr_auditor;
GO

-- C) ROLES: agrupan permisos por puesto de trabajo. Los permisos se dan  al rol una sola vez y cada persona nueva solo se agrega al rol.

IF DATABASE_PRINCIPAL_ID('rol_administrador') IS NULL CREATE ROLE rol_administrador;
IF DATABASE_PRINCIPAL_ID('rol_cajero')        IS NULL CREATE ROLE rol_cajero;
IF DATABASE_PRINCIPAL_ID('rol_reponedor')     IS NULL CREATE ROLE rol_reponedor;
IF DATABASE_PRINCIPAL_ID('rol_auditor')       IS NULL CREATE ROLE rol_auditor;
GO

-- Asignamos cada usuario a su rol (Moderador queda sin rol: se maneja con permisos directos)
ALTER ROLE rol_administrador ADD MEMBER Administrador;
ALTER ROLE rol_cajero        ADD MEMBER Cajero;
ALTER ROLE rol_reponedor     ADD MEMBER Reponedor;
ALTER ROLE rol_auditor       ADD MEMBER Auditor;
GO

-- D) GRANT / DENY / REVOKE

-- GRANT: OTORGA un permiso.
-- El Moderador puede ver, registrar y corregir datos de clientes.
GRANT SELECT, INSERT, UPDATE ON CLIENTE TO Moderador;
-- También le damos (por ahora) lectura de la tabla EMPLEADO.
GRANT SELECT ON EMPLEADO TO Moderador;

-- DENY: PROHÍBE un permiso y gana sobre cualquier GRANT (incluso de un rol).
-- Un moderador nunca debe borrar clientes (se perdería el historial de ventas).
DENY DELETE ON CLIENTE TO Moderador;

-- REVOKE: RETIRA un GRANT/DENY anterior (deja el permiso "sin definir").
-- EMPLEADO tiene sueldos, así que le quitamos al Moderador la lectura que le dimos arriba.
REVOKE SELECT ON EMPLEADO FROM Moderador;

-- Permisos amplios para el administrador (todas las tablas y vistas del esquema dbo)
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rol_administrador;
GRANT EXECUTE                        ON SCHEMA::dbo TO rol_administrador;

-- El auditor solo mira: lectura total, escritura prohibida y sin ver sueldos
GRANT SELECT                         ON SCHEMA::dbo TO rol_auditor;
DENY  INSERT, UPDATE, DELETE         ON SCHEMA::dbo TO rol_auditor;
DENY  SELECT                         ON EMPLEADO    TO rol_auditor;

-- Cajeros y reponedores NO deben ver sueldos de la tabla EMPLEADO
-- (verán la vista VW_EMPLEADOS_PUBLICO, que sí es segura)
DENY SELECT ON EMPLEADO TO rol_cajero;
DENY SELECT ON EMPLEADO TO rol_reponedor;
GO

-- PROCEDIMIENTOS ALMACENADOS
-- Regla común: primero se VALIDA (y se avisa con THROW si algo está mal) y recién después se escribe en las tablas. Los que tocan varias tablas usan transacción: o se guarda todo o no se guarda nada.

-- 1) SP_REGISTRAR_CLIENTE: da de alta un cliente nuevo

CREATE OR ALTER PROCEDURE SP_REGISTRAR_CLIENTE
    @DNI      CHAR(8),
    @NOMBRE   NVARCHAR(50),
    @APELLIDO NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM CLIENTE WHERE DNI = @DNI)
        THROW 50001, 'Ya existe un cliente registrado con ese DNI.', 1;

    INSERT INTO CLIENTE (DNI, NOMBRE_CLIENTE, APELLIDO_CLIENTE, FECHA_REGISTRO)
    VALUES (@DNI, @NOMBRE, @APELLIDO, GETDATE());

    SELECT DNI, NOMBRE_CLIENTE, APELLIDO_CLIENTE, FECHA_REGISTRO
    FROM CLIENTE WHERE DNI = @DNI;
END;
GO

-- 2) SP_ABRIR_VENTA: crea la cabecera de una venta y devuelve su ID
--    @ID_DETALLE = turno de caja abierto (DETALLE_CAJA) donde se atiende

CREATE OR ALTER PROCEDURE SP_ABRIR_VENTA
    @ID_COMPROBANTE INT,
    @ID_DETALLE     INT,
    @DNI            CHAR(8),
    @ID_VENTA       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM COMPROBANTE WHERE ID_COMPROBANTE = @ID_COMPROBANTE)
        THROW 50010, 'El tipo de comprobante no existe.', 1;
    IF NOT EXISTS (SELECT 1 FROM CLIENTE WHERE DNI = @DNI)
        THROW 50011, 'El cliente no está registrado. Use SP_REGISTRAR_CLIENTE primero.', 1;
    IF NOT EXISTS (SELECT 1 FROM DETALLE_CAJA WHERE ID_DETALLE = @ID_DETALLE AND HORARIO_FINAL IS NULL)
        THROW 50012, 'El turno de caja no existe o ya fue cerrado.', 1;

    INSERT INTO VENTA (ID_COMPROBANTE, ID_DETALLE, DNI, FECHA_VENTA)
    VALUES (@ID_COMPROBANTE, @ID_DETALLE, @DNI, GETDATE());

    SET @ID_VENTA = SCOPE_IDENTITY();
END;
GO

-- 3) SP_AGREGAR_PRODUCTO_VENTA: agrega un producto a una venta

CREATE OR ALTER PROCEDURE SP_AGREGAR_PRODUCTO_VENTA
    @ID_VENTA    INT,
    @ID_PRODUCTO INT,
    @CANTIDAD    INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PRECIO DECIMAL(10,2), @STOCK INT;

    IF @CANTIDAD <= 0
        THROW 50020, 'La cantidad debe ser mayor a cero.', 1;
    IF NOT EXISTS (SELECT 1 FROM VENTA WHERE ID_VENTA = @ID_VENTA)
        THROW 50021, 'La venta no existe.', 1;

    SELECT @PRECIO = PRECIO_VENTA FROM PRODUCTO WHERE ID_PRODUCTO = @ID_PRODUCTO;
    IF @PRECIO IS NULL
        THROW 50022, 'El producto no existe.', 1;

    SELECT @STOCK = ISNULL(SUM(CASE WHEN TIPO_MOVIMIENTO = 'E' THEN CANTIDAD_MOVIMIENTO
                                    ELSE -CANTIDAD_MOVIMIENTO END), 0)
    FROM MOVIMIENTO_INVENTARIO WHERE ID_PRODUCTO = @ID_PRODUCTO;
    IF @STOCK < @CANTIDAD
        THROW 50023, 'Stock insuficiente para completar la venta.', 1;

    SET XACT_ABORT ON;
    BEGIN TRAN;
        -- Si el producto ya estaba en la venta, se suma la cantidad (la PK no permite repetirlo)
        IF EXISTS (SELECT 1 FROM DETALLE_VENTA WHERE ID_VENTA = @ID_VENTA AND ID_PRODUCTO = @ID_PRODUCTO)
            UPDATE DETALLE_VENTA
            SET CANTIDAD_VENTA = CANTIDAD_VENTA + @CANTIDAD
            WHERE ID_VENTA = @ID_VENTA AND ID_PRODUCTO = @ID_PRODUCTO;
        ELSE
            INSERT INTO DETALLE_VENTA (ID_VENTA, ID_PRODUCTO, CANTIDAD_VENTA, PRECIO_UNITARIO)
            VALUES (@ID_VENTA, @ID_PRODUCTO, @CANTIDAD, @PRECIO);

        INSERT INTO MOVIMIENTO_INVENTARIO (ID_PRODUCTO, CANTIDAD_MOVIMIENTO, FECHA_MOVIMIENTO, TIPO_MOVIMIENTO)
        VALUES (@ID_PRODUCTO, @CANTIDAD, GETDATE(), 'S');
    COMMIT TRAN;
END;
GO

-- 4) SP_REGISTRAR_PAGO: registra un pago (o parte de un pago mixto) de una venta

CREATE OR ALTER PROCEDURE SP_REGISTRAR_PAGO
    @ID_VENTA INT,
    @ID_PAGO  INT,
    @MONTO    DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TOTAL DECIMAL(10,2), @PAGADO DECIMAL(10,2);

    IF @MONTO <= 0
        THROW 50030, 'El monto debe ser mayor a cero.', 1;
    IF NOT EXISTS (SELECT 1 FROM METODO_PAGO WHERE ID_PAGO = @ID_PAGO)
        THROW 50031, 'El método de pago no existe.', 1;

    SELECT @TOTAL = SUM(CANTIDAD_VENTA * PRECIO_UNITARIO)
    FROM DETALLE_VENTA WHERE ID_VENTA = @ID_VENTA;
    IF @TOTAL IS NULL
        THROW 50032, 'La venta no existe o aún no tiene productos.', 1;

    SELECT @PAGADO = ISNULL(SUM(MONTO_PAGO), 0) FROM DETALLE_METODO_PAGO WHERE ID_VENTA = @ID_VENTA;
    IF @PAGADO + @MONTO > @TOTAL
        THROW 50033, 'El pago excede el total de la venta.', 1;

    IF EXISTS (SELECT 1 FROM DETALLE_METODO_PAGO WHERE ID_VENTA = @ID_VENTA AND ID_PAGO = @ID_PAGO)
        THROW 50034, 'Ese método de pago ya fue registrado para esta venta.', 1;

    INSERT INTO DETALLE_METODO_PAGO (ID_VENTA, ID_PAGO, MONTO_PAGO, FECHA_PAGO)
    VALUES (@ID_VENTA, @ID_PAGO, @MONTO, GETDATE());

    SELECT @TOTAL AS TOTAL_VENTA, @PAGADO + @MONTO AS TOTAL_PAGADO, @TOTAL - (@PAGADO + @MONTO) AS SALDO;
END;
GO

-- 5) SP_REGISTRAR_COMPRA: crea la cabecera de una compra a un proveedor
--    Solo un REPONEDOR activo puede registrar compras

CREATE OR ALTER PROCEDURE SP_REGISTRAR_COMPRA
    @ID_EMPLEADO INT,
    @RUC         CHAR(11),
    @ID_COMPRA   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM REPONEDOR R
                   INNER JOIN EMPLEADO E ON E.ID_EMPLEADO = R.ID_EMPLEADO
                   WHERE R.ID_EMPLEADO = @ID_EMPLEADO AND E.ESTADO_EMPLEADO = 'A')
        THROW 50040, 'El empleado no es un reponedor activo.', 1;
    IF NOT EXISTS (SELECT 1 FROM PROVEEDOR WHERE RUC = @RUC)
        THROW 50041, 'El proveedor no existe.', 1;

    INSERT INTO COMPRA (ID_EMPLEADO, RUC, FECHA_COMPRA)
    VALUES (@ID_EMPLEADO, @RUC, GETDATE());

    SET @ID_COMPRA = SCOPE_IDENTITY();
END;
GO

-- 6) SP_AGREGAR_PRODUCTO_COMPRA: agrega un producto a una compra y registra una ENTRADA en MOVIMIENTO_INVENTARIO (el stock sube).

CREATE OR ALTER PROCEDURE SP_AGREGAR_PRODUCTO_COMPRA
    @ID_COMPRA   INT,
    @ID_PRODUCTO INT,
    @CANTIDAD    INT,
    @COSTO       DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @CANTIDAD <= 0 OR @COSTO <= 0
        THROW 50050, 'La cantidad y el costo deben ser mayores a cero.', 1;
    IF NOT EXISTS (SELECT 1 FROM COMPRA WHERE ID_COMPRA = @ID_COMPRA)
        THROW 50051, 'La compra no existe.', 1;
    IF NOT EXISTS (SELECT 1 FROM PRODUCTO WHERE ID_PRODUCTO = @ID_PRODUCTO)
        THROW 50052, 'El producto no existe.', 1;
    IF EXISTS (SELECT 1 FROM DETALLE_COMPRA WHERE ID_COMPRA = @ID_COMPRA AND ID_PRODUCTO = @ID_PRODUCTO)
        THROW 50053, 'Ese producto ya está en la compra.', 1;

    SET XACT_ABORT ON;
    BEGIN TRAN;
        INSERT INTO DETALLE_COMPRA (ID_COMPRA, ID_PRODUCTO, CANTIDAD_COMPRADA, COSTO_UNITARIO)
        VALUES (@ID_COMPRA, @ID_PRODUCTO, @CANTIDAD, @COSTO);

        INSERT INTO MOVIMIENTO_INVENTARIO (ID_PRODUCTO, CANTIDAD_MOVIMIENTO, FECHA_MOVIMIENTO, TIPO_MOVIMIENTO)
        VALUES (@ID_PRODUCTO, @CANTIDAD, GETDATE(), 'E');
    COMMIT TRAN;
END;
GO

-- 7) SP_REPORTE_VENTAS: ventas por día en un rango de fechas

CREATE OR ALTER PROCEDURE SP_REPORTE_VENTAS
    @FECHA_INICIO DATE,
    @FECHA_FIN    DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @FECHA_FIN < @FECHA_INICIO
        THROW 50060, 'La fecha final no puede ser menor que la inicial.', 1;

    SELECT CAST(V.FECHA_VENTA AS DATE)                  AS FECHA,
           COUNT(DISTINCT V.ID_VENTA)                   AS CANT_VENTAS,
           SUM(DV.CANTIDAD_VENTA)                       AS UNIDADES_VENDIDAS,
           SUM(DV.CANTIDAD_VENTA * DV.PRECIO_UNITARIO)  AS TOTAL_VENDIDO
    FROM VENTA V
    INNER JOIN DETALLE_VENTA DV ON DV.ID_VENTA = V.ID_VENTA
    WHERE V.FECHA_VENTA >= @FECHA_INICIO
      AND V.FECHA_VENTA <  DATEADD(DAY, 1, @FECHA_FIN)
    GROUP BY CAST(V.FECHA_VENTA AS DATE)
    ORDER BY FECHA;
END;
GO

-- VISTAS

-- 1) VW_STOCK_ACTUAL: stock de cada producto = entradas - salidas | ESTADO_STOCK: AGOTADO (<=0), REPONER (<=50) o NORMAL

CREATE OR ALTER VIEW VW_STOCK_ACTUAL AS
SELECT P.ID_PRODUCTO,
       P.NOMBRE_PRODUCTO AS PRODUCTO,
       C.NOMBRE_CATEGORIA AS CATEGORIA,
       ISNULL(SUM(CASE WHEN M.TIPO_MOVIMIENTO = 'E' THEN M.CANTIDAD_MOVIMIENTO END), 0) AS ENTRADAS,
       ISNULL(SUM(CASE WHEN M.TIPO_MOVIMIENTO = 'S' THEN M.CANTIDAD_MOVIMIENTO END), 0) AS SALIDAS,
       ISNULL(SUM(CASE WHEN M.TIPO_MOVIMIENTO = 'E' THEN M.CANTIDAD_MOVIMIENTO
                       ELSE -M.CANTIDAD_MOVIMIENTO END), 0) AS STOCK_ACTUAL,
       CASE WHEN ISNULL(SUM(CASE WHEN M.TIPO_MOVIMIENTO = 'E' THEN M.CANTIDAD_MOVIMIENTO
                                 ELSE -M.CANTIDAD_MOVIMIENTO END), 0) <= 0  THEN 'AGOTADO'
            WHEN ISNULL(SUM(CASE WHEN M.TIPO_MOVIMIENTO = 'E' THEN M.CANTIDAD_MOVIMIENTO
                                 ELSE -M.CANTIDAD_MOVIMIENTO END), 0) <= 50 THEN 'REPONER'
            ELSE 'NORMAL' END AS ESTADO_STOCK
FROM PRODUCTO P
INNER JOIN CATEGORIA C ON C.ID_CATEGORIA = P.ID_CATEGORIA
LEFT JOIN  MOVIMIENTO_INVENTARIO M ON M.ID_PRODUCTO = P.ID_PRODUCTO
GROUP BY P.ID_PRODUCTO, P.NOMBRE_PRODUCTO, C.NOMBRE_CATEGORIA;
GO

-- 2) VW_VENTAS_RESUMEN: una fila por venta con cliente, cajero, caja, comprobante, total vendido y total pagado

CREATE OR ALTER VIEW VW_VENTAS_RESUMEN AS
SELECT V.ID_VENTA,
       V.FECHA_VENTA,
       CL.NOMBRE_CLIENTE + N' ' + CL.APELLIDO_CLIENTE AS CLIENTE,
       CO.TIPO_COMPROBANTE,
       E.NOMBRE_EMPLEADO + N' ' + E.APELLIDO_EMPLEADO AS CAJERO,
       DC.NUMERO_CAJA,
       ISNULL(T.TOTAL_VENTA, 0)  AS TOTAL_VENTA,
       ISNULL(P.TOTAL_PAGADO, 0) AS TOTAL_PAGADO
FROM VENTA V
INNER JOIN CLIENTE      CL ON CL.DNI = V.DNI
INNER JOIN COMPROBANTE  CO ON CO.ID_COMPROBANTE = V.ID_COMPROBANTE
INNER JOIN DETALLE_CAJA DC ON DC.ID_DETALLE = V.ID_DETALLE
INNER JOIN EMPLEADO     E  ON E.ID_EMPLEADO = DC.ID_EMPLEADO
LEFT JOIN (SELECT ID_VENTA, SUM(CANTIDAD_VENTA * PRECIO_UNITARIO) AS TOTAL_VENTA
           FROM DETALLE_VENTA GROUP BY ID_VENTA) T ON T.ID_VENTA = V.ID_VENTA
LEFT JOIN (SELECT ID_VENTA, SUM(MONTO_PAGO) AS TOTAL_PAGADO
           FROM DETALLE_METODO_PAGO GROUP BY ID_VENTA) P ON P.ID_VENTA = V.ID_VENTA;
GO

-- 3) VW_COMPRAS_PROVEEDOR: una fila por compra con proveedor, reponedor, cantidad de productos distintos, unidades y costo total

CREATE OR ALTER VIEW VW_COMPRAS_PROVEEDOR AS
SELECT CP.ID_COMPRA,
       CP.FECHA_COMPRA,
       PV.NOMBRE_PROVEEDOR AS PROVEEDOR,
       PV.RUC,
       E.NOMBRE_EMPLEADO + N' ' + E.APELLIDO_EMPLEADO AS REGISTRADO_POR,
       COUNT(DCP.ID_PRODUCTO)                           AS PRODUCTOS_DISTINTOS,
       SUM(DCP.CANTIDAD_COMPRADA)                       AS UNIDADES_COMPRADAS,
       SUM(DCP.CANTIDAD_COMPRADA * DCP.COSTO_UNITARIO)  AS TOTAL_COMPRA
FROM COMPRA CP
INNER JOIN PROVEEDOR      PV  ON PV.RUC = CP.RUC
INNER JOIN EMPLEADO       E   ON E.ID_EMPLEADO = CP.ID_EMPLEADO
INNER JOIN DETALLE_COMPRA DCP ON DCP.ID_COMPRA = CP.ID_COMPRA
GROUP BY CP.ID_COMPRA, CP.FECHA_COMPRA, PV.NOMBRE_PROVEEDOR, PV.RUC,
         E.NOMBRE_EMPLEADO, E.APELLIDO_EMPLEADO;
GO

-- 4) VW_VENTAS_POR_CATEGORIA: unidades e importe vendido por categoría

CREATE OR ALTER VIEW VW_VENTAS_POR_CATEGORIA AS
SELECT C.NOMBRE_CATEGORIA AS CATEGORIA,
       SUM(DV.CANTIDAD_VENTA)                      AS UNIDADES_VENDIDAS,
       SUM(DV.CANTIDAD_VENTA * DV.PRECIO_UNITARIO) AS TOTAL_VENDIDO
FROM CATEGORIA C
INNER JOIN PRODUCTO      P  ON P.ID_CATEGORIA = C.ID_CATEGORIA
INNER JOIN DETALLE_VENTA DV ON DV.ID_PRODUCTO = P.ID_PRODUCTO
GROUP BY C.NOMBRE_CATEGORIA;
GO

-- 5) VW_PRODUCTOS_MAS_VENDIDOS: ranking de productos por unidades vendidas (para ver el top se consulta con ORDER BY o TOP)

CREATE OR ALTER VIEW VW_PRODUCTOS_MAS_VENDIDOS AS
SELECT P.ID_PRODUCTO,
       P.NOMBRE_PRODUCTO AS PRODUCTO,
       SUM(DV.CANTIDAD_VENTA)                      AS UNIDADES_VENDIDAS,
       SUM(DV.CANTIDAD_VENTA * DV.PRECIO_UNITARIO) AS TOTAL_VENDIDO
FROM PRODUCTO P
INNER JOIN DETALLE_VENTA DV ON DV.ID_PRODUCTO = P.ID_PRODUCTO
GROUP BY P.ID_PRODUCTO, P.NOMBRE_PRODUCTO;
GO

-- 6) VW_EMPLEADOS_PUBLICO: empleados SIN sueldo ni teléfono ni correo, con su puesto (CAJERO / REPONEDOR) y turno. Es la vista segura de EMPLEADO.

CREATE OR ALTER VIEW VW_EMPLEADOS_PUBLICO AS
SELECT E.ID_EMPLEADO,
       E.NOMBRE_EMPLEADO + N' ' + E.APELLIDO_EMPLEADO AS EMPLEADO,
       CASE WHEN CJ.ID_EMPLEADO IS NOT NULL THEN N'CAJERO'
            WHEN R.ID_EMPLEADO  IS NOT NULL THEN N'REPONEDOR'
            ELSE N'SIN PUESTO' END AS PUESTO,
       CJ.TURNO,
       E.FECHA_CONTRATO,
       CASE E.ESTADO_EMPLEADO WHEN 'A' THEN N'ACTIVO' ELSE N'INACTIVO' END AS ESTADO
FROM EMPLEADO E
LEFT JOIN CAJERO    CJ ON CJ.ID_EMPLEADO = E.ID_EMPLEADO
LEFT JOIN REPONEDOR R  ON R.ID_EMPLEADO  = E.ID_EMPLEADO;
GO

-- PERMISOS FINALES (se dan aquí porque los procedimientos y vistas ya existen). 

-- Cajero: atiende ventas, registra clientes y consulta catálogo/stock
GRANT EXECUTE ON SP_REGISTRAR_CLIENTE        TO rol_cajero;
GRANT EXECUTE ON SP_ABRIR_VENTA              TO rol_cajero;
GRANT EXECUTE ON SP_AGREGAR_PRODUCTO_VENTA   TO rol_cajero;
GRANT EXECUTE ON SP_REGISTRAR_PAGO           TO rol_cajero;
GRANT SELECT  ON PRODUCTO                    TO rol_cajero;
GRANT SELECT  ON CATEGORIA                   TO rol_cajero;
GRANT SELECT  ON CLIENTE                     TO rol_cajero;
GRANT SELECT  ON COMPROBANTE                 TO rol_cajero;
GRANT SELECT  ON METODO_PAGO                 TO rol_cajero;
GRANT SELECT  ON VW_STOCK_ACTUAL             TO rol_cajero;
GRANT SELECT  ON VW_EMPLEADOS_PUBLICO        TO rol_cajero;

-- Reponedor: registra compras y revisa stock y proveedores
GRANT EXECUTE ON SP_REGISTRAR_COMPRA         TO rol_reponedor;
GRANT EXECUTE ON SP_AGREGAR_PRODUCTO_COMPRA  TO rol_reponedor;
GRANT SELECT  ON PRODUCTO                    TO rol_reponedor;
GRANT SELECT  ON PROVEEDOR                   TO rol_reponedor;
GRANT SELECT  ON VW_STOCK_ACTUAL             TO rol_reponedor;
GRANT SELECT  ON VW_COMPRAS_PROVEEDOR        TO rol_reponedor;
GRANT SELECT  ON VW_EMPLEADOS_PUBLICO        TO rol_reponedor;

-- Moderador: además de clientes, puede registrar clientes por procedimiento y ver reportes de ventas
GRANT EXECUTE ON SP_REGISTRAR_CLIENTE        TO Moderador;
GRANT SELECT  ON VW_VENTAS_RESUMEN           TO Moderador;
GO

-- PRUEBAS DE SEGURIDAD, PROCEDIMIENTOS Y VISTAS

-- A) Pruebas de permisos con EXECUTE AS (nos "disfrazamos" del usuario) REVERT siempre vuelve a nuestro usuario original.

-- A.1) Moderador: puede leer clientes ...
EXECUTE AS USER = 'Moderador';
SELECT TOP 3 DNI, NOMBRE_CLIENTE, APELLIDO_CLIENTE FROM CLIENTE;
REVERT;

-- A.2) ... pero NO puede borrarlos (DENY) ni ver sueldos (REVOKE)
BEGIN TRY
    EXECUTE AS USER = 'Moderador';
    DELETE FROM CLIENTE WHERE DNI = '47460468';
    REVERT;
END TRY
BEGIN CATCH
    REVERT;
    PRINT 'Moderador / DELETE bloqueado: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXECUTE AS USER = 'Moderador';
    SELECT SUELDO_BASE FROM EMPLEADO;
    REVERT;
END TRY
BEGIN CATCH
    REVERT;
    PRINT 'Moderador / SELECT EMPLEADO bloqueado: ' + ERROR_MESSAGE();
END CATCH;

-- A.3) Cajero: no ve la tabla EMPLEADO, pero sí la vista pública

BEGIN TRY
    EXECUTE AS USER = 'usr_cajero';
    SELECT * FROM EMPLEADO;
    REVERT;
END TRY
BEGIN CATCH
    REVERT;
    PRINT 'Cajero / SELECT EMPLEADO bloqueado: ' + ERROR_MESSAGE();
END CATCH;

EXECUTE AS USER = 'usr_cajero';
SELECT * FROM VW_EMPLEADOS_PUBLICO;
REVERT;

-- B) Prueba del flujo completo de una venta con procedimientos. Va dentro de una transacción con ROLLBACK final: se ve el resultado pero los datos del proyecto quedan intactos.

BEGIN TRAN;

    DECLARE @NUEVA_VENTA INT;

    -- Comprobante 1 = BOLETA, turno de caja 44 (abierto), cliente existente
    
    EXEC SP_ABRIR_VENTA @ID_COMPROBANTE = 1, @ID_DETALLE = 44, @DNI = '78473414', @ID_VENTA = @NUEVA_VENTA OUTPUT;

    EXEC SP_AGREGAR_PRODUCTO_VENTA @ID_VENTA = @NUEVA_VENTA, @ID_PRODUCTO = 1, @CANTIDAD = 2;   -- Azúcar rubia
    EXEC SP_AGREGAR_PRODUCTO_VENTA @ID_VENTA = @NUEVA_VENTA, @ID_PRODUCTO = 4, @CANTIDAD = 1;   -- Arroz extra 5 kg

    -- Total = 2*4.80 + 1*24.90 = 34.50 -> pago mixto 20 efectivo + 14.50 Yape
    
    EXEC SP_REGISTRAR_PAGO @ID_VENTA = @NUEVA_VENTA, @ID_PAGO = 1, @MONTO = 20.00;
    EXEC SP_REGISTRAR_PAGO @ID_VENTA = @NUEVA_VENTA, @ID_PAGO = 4, @MONTO = 14.50;

    SELECT * FROM VW_VENTAS_RESUMEN WHERE ID_VENTA = @NUEVA_VENTA;
    SELECT * FROM VW_STOCK_ACTUAL   WHERE ID_PRODUCTO IN (1, 4);

ROLLBACK TRAN;

-- C) Prueba de una validación: pedir más de lo que hay en stock debe fallar

BEGIN TRY
    DECLARE @VENTA_TEST INT;
    EXEC SP_ABRIR_VENTA 1, 44, '78473414', @VENTA_TEST OUTPUT;
    EXEC SP_AGREGAR_PRODUCTO_VENTA @VENTA_TEST, 55, 99999;
END TRY
BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();

    -- Esta venta de prueba quedó sin productos: la eliminamos
   
   DELETE FROM VENTA WHERE ID_VENTA = @VENTA_TEST;
END CATCH;

-- D) Prueba de una compra al proveedor con procedimientos (también con ROLLBACK)

BEGIN TRAN;
    DECLARE @NUEVA_COMPRA INT;
    EXEC SP_REGISTRAR_COMPRA @ID_EMPLEADO = 5, @RUC = '20601234567', @ID_COMPRA = @NUEVA_COMPRA OUTPUT;
    EXEC SP_AGREGAR_PRODUCTO_COMPRA @ID_COMPRA = @NUEVA_COMPRA, @ID_PRODUCTO = 55, @CANTIDAD = 60, @COSTO = 29.00;
    SELECT * FROM VW_COMPRAS_PROVEEDOR WHERE ID_COMPRA = @NUEVA_COMPRA;
    SELECT * FROM VW_STOCK_ACTUAL      WHERE ID_PRODUCTO = 55;
ROLLBACK TRAN;

-- E) Reporte de ventas por rango de fechas

EXEC SP_REPORTE_VENTAS @FECHA_INICIO = '20261005', @FECHA_FIN = '20261011';

-- F) Consultas de ejemplo sobre las vistas

SELECT * FROM VW_STOCK_ACTUAL            ORDER BY STOCK_ACTUAL;
SELECT * FROM VW_STOCK_ACTUAL            WHERE ESTADO_STOCK <> 'NORMAL';
SELECT * FROM VW_COMPRAS_PROVEEDOR       ORDER BY FECHA_COMPRA;
SELECT * FROM VW_VENTAS_POR_CATEGORIA    ORDER BY TOTAL_VENDIDO DESC;
SELECT TOP 10 * FROM VW_PRODUCTOS_MAS_VENDIDOS ORDER BY UNIDADES_VENDIDAS DESC;
SELECT TOP 10 * FROM VW_VENTAS_RESUMEN   ORDER BY TOTAL_VENTA DESC;
GO

-- ZONA DE PRÁCTICA (DDL y DML básicos)

SELECT * INTO PRODUCTO_PRACTICA FROM PRODUCTO;

-- Consultas básicas

SELECT * FROM PRODUCTO_PRACTICA ORDER BY PRECIO_VENTA DESC;
SELECT * FROM PRODUCTO_PRACTICA WHERE PRECIO_VENTA > 10;
SELECT * FROM PRODUCTO_PRACTICA WHERE ID_PRODUCTO % 2 = 0;

-- TRUNCATE: vacía la tabla

TRUNCATE TABLE PRODUCTO_PRACTICA;

-- ALTER TABLE: agregar y quitar una columna

ALTER TABLE PRODUCTO_PRACTICA ADD MARCA VARCHAR(50) NOT NULL;
ALTER TABLE PRODUCTO_PRACTICA DROP COLUMN MARCA;

-- INSERT de práctica y DELETE con condición

INSERT INTO PRODUCTO_PRACTICA (ID_CATEGORIA, NOMBRE_PRODUCTO, DESCRIPCION_PRODUCTO, PRECIO_VENTA) VALUES
(1, N'Arroz Costeño 5kg',   N'Arroz superior de grano largo en bolsa de 5 kg',      24.90),
(2, N'Leche Gloria 400g',   N'Leche evaporada entera en lata de 400 g',             4.50),
(3, N'Inca Kola 1.5L',      N'Gaseosa sabor original en botella de 1.5 litros',     7.50),
(4, N'Galletas Oreo',       N'Galletas de chocolate con crema, paquete de 6 unid.', 2.80);
DELETE FROM PRODUCTO_PRACTICA WHERE ID_PRODUCTO % 2 = 0;
SELECT * FROM PRODUCTO_PRACTICA;

-- CREATE TABLE y DROP TABLE de práctica

CREATE TABLE MOVIMIENTOS (
    ID_MOVIMIENTO INT PRIMARY KEY,
    CANTIDAD_MOVIMIENTO VARCHAR(100),
    TIPO_MOVIMIENTO VARCHAR(50) NOT NULL,
    FECHA_MOVIMIENTO VARCHAR(20) NOT NULL
);
DROP TABLE MOVIMIENTOS;

-- UPDATE: actualizamos la descripción de la categoría "Mascotas" (ID_CATEGORIA = 10)

UPDATE CATEGORIA
SET DESCRIP_CATEGORIA = 'Alimento, snacks y accesorios para perros, gatos y otras mascotas'
WHERE ID_CATEGORIA = 10;

-- Limpiamos la tabla de práctica

DROP TABLE PRODUCTO_PRACTICA;

----------------------------



-- GUARDAR EL STOCK ANTES DE LA COMPRA

IF OBJECT_ID('tempdb..#StockAntes') IS NOT NULL
    DROP TABLE #StockAntes;

SELECT
    P.ID_PRODUCTO,
    P.NOMBRE_PRODUCTO,
    C.NOMBRE_CATEGORIA,
    COALESCE(
        SUM(
            CASE
                WHEN M.TIPO_MOVIMIENTO = 'E'
                    THEN M.CANTIDAD_MOVIMIENTO
                WHEN M.TIPO_MOVIMIENTO = 'S'
                    THEN -M.CANTIDAD_MOVIMIENTO
                ELSE 0
            END
        ), 0
    ) AS STOCK_ANTES
INTO #StockAntes
FROM dbo.PRODUCTO P
INNER JOIN dbo.CATEGORIA C
    ON P.ID_CATEGORIA = C.ID_CATEGORIA
LEFT JOIN dbo.MOVIMIENTO_INVENTARIO M
    ON P.ID_PRODUCTO = M.ID_PRODUCTO
GROUP BY
    P.ID_PRODUCTO,
    P.NOMBRE_PRODUCTO,
    C.NOMBRE_CATEGORIA;

-- MOSTRAR EL STOCK ANTES DE COMPRAR

SELECT *
FROM #StockAntes
ORDER BY NOMBRE_PRODUCTO;

-------------------------------------


USE BASE_DATOS_MI_BARRIO_MARKET;
GO

DECLARE @NumeroVenta INT = 180;

-- =============================================
-- 1. DATOS GENERALES DE LA VENTA
-- =============================================

SELECT
    V.ID_VENTA AS [NUMERO DE VENTA],
    V.FECHA_VENTA AS [FECHA DE VENTA],
    V.DNI AS [DNI DEL CLIENTE],

    CONCAT(C.NOMBRE_CLIENTE, ' ',
           C.APELLIDO_CLIENTE) AS [CLIENTE],

    CO.TIPO_COMPROBANTE AS [COMPROBANTE],

    DC.NUMERO_CAJA AS [NUMERO DE CAJA],
    DC.HORARIO_INICIO AS [INICIO DE TURNO],
    DC.HORARIO_FINAL AS [FIN DE TURNO],

    E.ID_EMPLEADO AS [ID DEL CAJERO],

    CONCAT(E.NOMBRE_EMPLEADO, ' ',
           E.APELLIDO_EMPLEADO) AS [CAJERO],

    CJ.TURNO AS [TURNO],

    CA.ESTADO_CAJA AS [ESTADO DE CAJA],
    CA.MONTO_APERTURA AS [MONTO DE APERTURA],
    CA.MONTO_CIERRE AS [MONTO DE CIERRE],

    (SELECT SUM(DV.CANTIDAD_VENTA)
     FROM DETALLE_VENTA DV
     WHERE DV.ID_VENTA = V.ID_VENTA)
     AS [CANTIDAD DE UNIDADES],

    (SELECT SUM(DV.CANTIDAD_VENTA * DV.PRECIO_UNITARIO)
     FROM DETALLE_VENTA DV
     WHERE DV.ID_VENTA = V.ID_VENTA)
     AS [TOTAL DE VENTA]

FROM VENTA V

LEFT JOIN CLIENTE C
    ON V.DNI = C.DNI

LEFT JOIN COMPROBANTE CO
    ON V.ID_COMPROBANTE = CO.ID_COMPROBANTE

LEFT JOIN DETALLE_CAJA DC
    ON V.ID_DETALLE = DC.ID_DETALLE

LEFT JOIN CAJA CA
    ON DC.NUMERO_CAJA = CA.NUMERO_CAJA

LEFT JOIN CAJERO CJ
    ON DC.ID_EMPLEADO = CJ.ID_EMPLEADO

LEFT JOIN EMPLEADO E
    ON DC.ID_EMPLEADO = E.ID_EMPLEADO

WHERE V.ID_VENTA = @NumeroVenta;


-- =============================================
-- 2. PRODUCTOS VENDIDOS
-- =============================================

SELECT
    DV.ID_VENTA AS [NUMERO DE VENTA],
    P.ID_PRODUCTO,
    P.NOMBRE_PRODUCTO AS [PRODUCTO],
    P.DESCRIPCION_PRODUCTO AS [DESCRIPCION],
    CAT.NOMBRE_CATEGORIA AS [CATEGORIA],
    DV.CANTIDAD_VENTA AS [CANTIDAD],
    DV.PRECIO_UNITARIO AS [PRECIO UNITARIO],

    (DV.CANTIDAD_VENTA * DV.PRECIO_UNITARIO)
    AS [SUBTOTAL]

FROM DETALLE_VENTA DV

INNER JOIN PRODUCTO P
    ON DV.ID_PRODUCTO = P.ID_PRODUCTO

LEFT JOIN CATEGORIA CAT
    ON P.ID_CATEGORIA = CAT.ID_CATEGORIA

WHERE DV.ID_VENTA = @NumeroVenta

ORDER BY P.NOMBRE_PRODUCTO;


-- =============================================
-- 3. METODOS DE PAGO
-- =============================================

SELECT
    DMP.ID_VENTA AS [NUMERO DE VENTA],
    MP.ID_PAGO,
    MP.METODO_PAGO AS [FORMA DE PAGO],
    DMP.MONTO_PAGO AS [IMPORTE],
    DMP.FECHA_PAGO AS [FECHA DE PAGO]

FROM DETALLE_METODO_PAGO DMP

INNER JOIN METODO_PAGO MP
    ON DMP.ID_PAGO = MP.ID_PAGO

WHERE DMP.ID_VENTA = @NumeroVenta

ORDER BY DMP.FECHA_PAGO;
