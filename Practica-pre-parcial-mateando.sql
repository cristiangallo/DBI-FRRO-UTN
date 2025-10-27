-- Tecnicatura Universitaria en Programación FRRO - UTN
-- Prácticas Pre Parcial de Bases de Datos I
-- Práctica Pre-Parcial SQL sobre Mateando
-- AUS Cristián M. Gallo
	
-- Dado el diagrama de la resolución sugerida, escribí las consultas necesarias que permitan:
/*
SELECT 
FROM
JOIN
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT
;
*/

/*
	a. (1 punto) Informar características de los productos cuyo nombre comience
		con “ma” y tengan una capacidad mayor a 500 cc, ordenados de mayor a
		menor por capacidad:
	---------------------------------------------	
	|Producto |Tipo de Producto | Material ↓↓↓↓↓|
    ---------------------------------------------
*/
SELECT P.nombre AS "Producto",
	TP.desc_producto AS "Tipo de producto",
	M.material AS "Material"
FROM `mateando`.`productos` AS P INNER JOIN `mateando`.`tipos_productos` AS TP
	ON P.idTipProducto=TP.codigo
INNER JOIN `mateando`.`materiales` AS M
	ON P.idMaterial=M.codigo
WHERE P.nombre LIKE "ma%" AND P.capacidad > 500
ORDER BY P.capacidad DESC;


/*
	b. (1 punto) Informar el precio vigente a hoy del producto mate-listo de 1000 cc.
	--------------------------
    |Código |Producto |Precio|
    --------------------------
*/
SELECT
	Prod.codigo, 
	Prod.nombre, 
	hist.precio 
FROM Productos AS Prod INNER JOIN HistoPrecios AS hist
	ON Prod.codigo = hist.codigo
WHERE Prod.nombre = "mate-listo" AND prod.capacidad = 1000 and fechaDesde <= CURDATE()
ORDER BY fechaDesde DESC 
LIMIT 1;

SELECT 
	PRO.codigo "Código",
	PRO.nombre "Producto",
	HIS.precio "Precio"
FROM `mateando`.`productos` PRO  INNER JOIN `mateando`.`histoprecios` HIS 
	ON PRO.codigo = HIS.codigo
WHERE PRO.nombre = "mate-listo" AND PRO.capacidad = 1000 
	AND HIS.fechaDesde = (
		SELECT MAX(fechaDesde) FROM `mateando`.`histoprecios`
			WHERE fechaDesde <= CURDATE() AND PRO.nombre = "mate-listo" AND prod.capacidad = 1000);


/*
	c. (1 punto) Informar vendedores junto con su supervisor, en el caso de que un
		vendedor no tenga supervisión informar “Sin supervisión”.
    -------------------------------------------------------------------------------------------------------------    
	|Legajo |Empleado (Nombre y apellido) |Fecha Ingreso (dd/mm/YYYY) |Antigüedad |Supervisor (Nombre y apellido |
    -------------------------------------------------------------------------------------------------------------
	Ayudín para calcular la antigüedad:
	year(curdate()) - year(fecha_ingreso) - (right(curdate(), 5) < right(fecha_ingreso, 5))
*/

SELECT V.legajo "Legajo", CONCAT(V.nombre, " ", V.apellido) "Empleado",
	DATE_FORMAT(V.fecha_ingreso, "%d/%m/%Y") "Fecha Ingreso", 
    YEAR(curdate()) - YEAR(V.fecha_ingreso) - (RIGHT(curdate(), 5) < RIGHT(V.fecha_ingreso, 5)) "Antigüedad",
	-- COALESCE(CONCAT(S.nombre, " ", S.apellido), "Sin supervisión") "Supervisor"
	IFNULL(CONCAT(S.nombre, " ", S.apellido), "Sin supervisión") "Supervisor"
FROM `mateando`.`vendedores` V LEFT JOIN `mateando`.`vendedores` S ON V.legajo_supervisor = S.legajo;

/*
	d. (1 punto) Informar los proveedores de la localidad “Rosario” que hayan
		provisto “Bombilla 7cms”.
	-------------------------------------------------------------
	|Razón Social |Teléfono |Dirección (calle altura, localidad)|
    -------------------------------------------------------------
*/

/*
	e. (1 punto) Insertar el producto “Bombilla 7cms”, tipo de producto “Bombillas” y material “Acero”
*/

-- WHERE descripcion="Bombillas" esto solo lo puedo hacer porque el atrib. descripcion es de tipo UNIQUE
SET @idTipProducto=(SELECT codigo from TiposProductos WHERE descripcion="Bombillas");
SET @idMaterial=(SELECT codigo from Materiales WHERE material="Acero");
INSERT INTO PRODUCTOS VALUES (
	NULL, "Bombilla 7cms", NULL, "Cromado", @idTipProducto, @idMaterial 
);

-- otra forma
INSERT INTO PRODUCTOS VALUES (
	NULL, "Bombilla 7cms", NULL, "Cromado",
    (SELECT codigo from TiposProductos WHERE descripcion="Bombillas"), 
    (SELECT codigo from Materiales WHERE material="Acero")
);

/*
	f. (2 puntos) Informar las órdenes de compra cuyos montos totales sean
		iguales o superiores a $100.000 y que se hayan realizado en septiembre de
		este año ordenadas por fecha ascendente.
	-----------------------------------------------------------------------------
    |Nro Comp. |Fecha (dd/mm/yyyy) |Monto ($xxx.xx) |Cliente (nombre y apellido)|
    -----------------------------------------------------------------------------
*/
SELECT 
	C.nrocom "Nro Comp.", 
    DATE_FORMAT(fecha, "%d/%m/%Y") "Fecha", 
    CONCAT("$ ", SUM(cantidad * precio_unit)) "Monto",
    CONCAT(CLI.nombre, " ", CLI.apellido) "Cliente"
FROM `mateando`.`Compras` C INNER JOIN `mateando`.`DetCompras` DC ON C.nrocom=DT.nrocom
	INNER JOIN `mateando`.`Clientes` CLI ON C.dni=CLI.dni
WHERE fecha BETWEEN "2025-09-01" and "2025-09-30"
	-- MONTH(fecha) = 9 and YEAR(fecha) = YEAR(CURDATE()) 
GROUP BY DC.nrocom
HAVING SUM(cantidad * precio_unit) >= 100000
ORDER BY fecha DESC
;

/*
	g. (2 puntos) Informar las órdenes donde se hayan comprado 20 o más
	unidades en total, ordenado por unidades descendente.
    ---------------------------------------------------------
	|Nro Comp. |fecha (dd/mm/YYYY) |Unidades ↓↓↓↓↓ |Cliente |
    ---------------------------------------------------------
*/

SELECT 
	C.nrocom "Nro Comp.", 
    DATE_FORMAT(fecha, "%d/%m/%Y") "Fecha", 
    SUM(cantidad) "Unidades",
    CONCAT(CLI.nombre, " ", CLI.apellido) "Cliente"
FROM `mateando`.`Compras` C INNER JOIN `mateando`.`DetCompras` DC ON C.nrocom=DT.nrocom
	INNER JOIN `mateando`.`Clientes` CLI ON C.dni=CLI.dni
GROUP BY DC.nrocom
HAVING SUM(cantidad) >= 20
ORDER BY SUM(cantidad) DESC
-- ORDER BY "Unidades" DESC
-- ORDER BY 3 DESC
;

/*
	h. (2 puntos) Informar los clientes que hayan realizado más de dos compras por
	mes, ordenado por cantidad de compras.
	------------------------------------------------------------------------	
    |Cliente (nombre y apellido) |Mes (mm/YYYY) |Cantidad de compras ↓↓↓↓↓ |
    ------------------------------------------------------------------------
*/

/*
	i. (2 puntos) Informar cantidad de productos por tipo de producto y material,
	ordenado en forma descendente por cantidad.
    ----------------------------------------------------------
	|Tipo de producto |Material |Cantidad de productos ↓↓↓↓↓ |
    ----------------------------------------------------------
*/

SELECT 
	TP.desc_producto AS "Tipo de producto",
    M.material AS "Material", 
	COUNT(*) "Cantidad de productos"
FROM `mateando`.`productos` AS P 
	INNER JOIN `mateando`.`tipos_productos` AS TP ON P.idTipProducto=TP.codigo
	INNER JOIN `mateando`.`materiales` AS M ON P.idMaterial=M.codigo
GROUP BY idTipProducto, idMaterial
ORDER BY 3 DESC;
-- ORDER BY COUNT(*) DESC;
-- ORDER BY "Cantidad de productos" DESC;


/*j. (2 puntos) Informar los productos que no registren compra.
    -------------------
    |Código |Producto |
	-------------------
*/

SELECT P.codigo "Código", P.nombre "Producto"
FROM `mateando`.`Productos` P LEFT JOIN `mateando`.`DetCompras` DC ON P.codigo=DC.cod_producto
WHERE DC.cod_producto IS NULL;



-- con subconsulta
SELECT P.codigo "Código", P.nombre "Producto"
FROM `mateando`.`Productos` P
WHERE NOT EXISTS (
	SELECT * FROM `mateando`.`DetCompras` DC 
		WHERE P.cod_producto=DC.cod_producto);

