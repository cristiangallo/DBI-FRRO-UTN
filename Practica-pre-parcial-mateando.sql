-- Tecnicatura Universitaria en Programación FRRO - UTN
-- Prácticas Pre Parcial de Bases de Datos I
-- Práctica Pre-Parcial SQL sobre Mateando
-- AUS Cristián M. Gallo
	
-- Dado el diagrama de la resolución sugerida, escribí las consultas necesarias que permitan:

/*
	a. (1 punto) Informare características de los productos cuyo nombre comience
		con “ma” y tengan una capacidad mayor a 500 cc, ordenados de mayor a
		menor por peso máximo:
	-------------------------------------------	
	|Producto |Tipo de Producto Material ↓↓↓↓↓|
    -------------------------------------------
*/

/*
	b. (1 punto) Informar el precio vigente a hoy del producto mate-listo de 1000 cc.
	--------------------------
    |Código |Producto |Precio|
    --------------------------
*/

/*
	c. (1 punto) Informar vendedores junto con su supervisor, en el caso de que un
		vendedor no tenga supervisión informar “Sin supervisión”.
    -------------------------------------------------------------------------------------------------------------    
	|Legajo |Empleado (Nombre y apellido |Fecha Ingreso (dd/mm/YYYY) |Antigüedad |Supervisor (Nombre y apellido |
    -------------------------------------------------------------------------------------------------------------
	Ayudín para calcular la antigüedad:
	year(curdate()) - year(fecha_ingreso) - (right(curdate(), 5) < right(fecha_ingreso 5))
*/


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

/*
	f. (2 puntos) Informar las órdenes de compra cuyos montos totales sean
		iguales o superiores a $100.000 y que se hayan realizado en septiembre de
		este año ordenadas por fecha ascendente.
	-----------------------------------------------------------------------------
    |Nro Comp. |Fecha (dd/mm/yyyy) |Monto ($xxx.xx) |Cliente (nombre y apellido)|
    -----------------------------------------------------------------------------
*/
/*
	g. (2 puntos) Informar las órdenes donde se hayan comprado 20 o más
	unidades en total, ordenado por unidades descendente.
    ---------------------------------------------------------
	|Nro Comp. |fecha (dd/mm/YYYY) |Unidades ↓↓↓↓↓ |Cliente |
    ---------------------------------------------------------
*/

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

/*j. (2 puntos) Informar los productos que no registren compra..
    -------------------
    |Código |Producto |
	-------------------
*/