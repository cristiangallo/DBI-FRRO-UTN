-- Ejercitación Gestión de arbolado público
-- Dado el diagrama modelo relacional, escribí las consultas necesarias que permitan:
/*
a)(1 punto) Informar todos los ejemplares cuyo nombre científico comience con “Platanus”, con estado vital “vivo en pie”, 
estado sanitario “malo” ó “seco”, plantados antes del 31 de diciembre de 1990, ordenados por riesgo descendente y fecha de plantación ascendente :

|ID Municipal |Nombre científico |Fecha plan. (dd/mm/yyyy)↑↑↑ |Riesgo ↓↓↓ |Est. Sanitario |
*/
SELECT id_munipal "ID Municipal", nombre_cientifico "Nombre científico", 
	DATE_FORMAT(fecha_plantacion, "%d/%m/%Y") "Fecha plan. (dd/mm/yyyy)↑↑↑", 
	riesgo "Riesgo ↓↓↓", nivel "Est. Sanitario"
FROM ejemplares EJ 
	JOIN especies ES ON EJ.id_especie=ES.id 
    JOIN estados_sanitarios EST ON EJ.id_estado=EST.id
    JOIN estados_vitales VIT ON EJ.id_estado_vital=VIT.id
    JOIN nivel_riesgo RIE ON EJ.id_riesgo=RIE.id
WHERE nombre_cientifico LIKE "Platanus%" and estado="vivo en pie" and
	descripcion in ("malo", "seco") and fecha_plantacion < "1990-12-31"
ORDER BY riesgo desc, fecha_plantacion ASC;

/*Errores frecuentes
	and descripcion = "malo" or descripcion = "seco" and fecha_plantacion ... precedencia del operador
	date_format (fecha_plantacion, "%d/%m/%Y") < "31/12/1990" comparar strings en vez de fechas
    fecha_plantacion >= "1990-12-31"
*/


/*
b)(1 punto) Realizar un informe detallado de los reclamos recepcionados 
entre el 21 de septiembre de 2024 y 21 de diciembre de 2025 ingresado por “línea telefónica 147” ordenados por fecha de reclamo ascendente :
|ID Recl. |Nombre común |Fecha reclamo (dd/mm/yyyy)↑↑↑ |Motivo reclamo |Est. Sanitario |
*/
SELECT id "ID Recl.", nombre_comun "Nombre común", 
	DATE_FORMAT(fecha, "%d/%m/%Y") "Fecha reclamo (dd/mm/yyyy)↑↑↑", 
	motivo "Motivo", nivel "Est. Sanitario"
FROM ejemplares EJ 
	JOIN especies ES ON EJ.id_especie=ES.id 
    JOIN estados_sanitarios EST ON EJ.id_estado=EST.id
    JOIN reclamos REC ON EJ.id=REC.id_ejemplar
    JOIN motivos_reclamos MR ON REC.id_motivo=MR.id
    JOIN canales CAN ON REC.id_canal=CAN.id
WHERE fecha between "2024-09-21" and "2025-12-21" and canal="línea telefónica 147"
ORDER BY fecha ASC;

/*Errores frecuentes
	unir tablas de más, por ejemplo la intermedia estados_reclamos para no sacar nada
*/


/*
c)(1 punto) Informar las especies que no hayan generado reclamos en los últimos 3 años:
|Nombre común |Nombre científico |Diámetro |Alt. máxima |
*/
SELECT nombre_comun "Nombre común", nombre_cientifico "Nombre científico", diametro "Diámetro", altura_maxima "Alt. máxima"
FROM ejemplares EJ 
	JOIN especies ES ON EJ.id_especie=ES.id 
WHERE NOT EXISTS (
	SELECT 1 FROM reclamos REC 
		WHERE EJ.id=REC.id_ejemplar AND fecha >= DATE_ADD(curdate(), INTERVAL -3 YEAR));

SELECT nombre_comun "Nombre común", nombre_cientifico "Nombre científico", diametro "Diámetro", altura_maxima "Alt. máxima"
FROM ejemplares EJ 
	JOIN especies ES ON EJ.id_especie=ES.id 
    left JOIN reclamos REC ON REC.id_ejemplar=EJ.id
WHERE REC.id is null AND fecha >= DATE_ADD(curdate(), INTERVAL -3 YEAR)  # DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
group by ES.id
HAVING count(REC.id)=0;  # <-- el having podemos omitirlo porque la condición REC.id is null hace para todos los grupos count(REC.id)=0

/*Errores frecuentes
	se piden "especies" no ejemplares...
    agrupar pero no hacer el having
    subconsulta no perfomante, son 420000 arboles actualmente con varios millones de reclamos EJ.id NOT IN Select R.id_ejemplar FROM reclamos...
*/


/*
d)(2 punto) Informar cantidad de reclamos que no hayan sido resueltos por estado, ordenados por cantidad de reclamos en forma descendente.
|Estado |Cant. de reclamos ↓↓↓ |
*/

SELECT e.estado "Estado", COUNT(*) AS "Cant. de reclamos ↓↓↓"
FROM estados_reclamos ER JOIN estados E ON E.id = ER.id_estado
WHERE ER.id = (
  SELECT ER2.id
  FROM estados_reclamos ER2
  WHERE ER2.id_reclamo = ER.id_reclamo
  ORDER BY ER2.fecha DESC, ER2.id DESC
  LIMIT 1
) AND E.estado <> 'Resuelto'
GROUP BY E.estado
ORDER BY cantidad DESC;

/*Errores frecuentes
	contar todos los estados por los que pasó el reclamo, solo se debe contar el estado actual
*/


/*
e)(2 punto) Para obtener un recuento anual, se necesita un listado con los datos de todas las especies y 
la cantidad de ejemplares que hay plantados de cada una (estado vital: vivo en pie). 
En el caso que no haya, mostrar “Sin ejemplares”.
|Nombre común |Nombre científico |Cant. de ejemplares |
*/

SELECT 
	nombre_comun "Nombre común", 
	nombre_cientifico "Nombre científico", 
	CASE WHEN COUNT(EJ.id) = 0 THEN 
		'Sin ejemplares'
	ELSE CAST(COUNT(EJ.id) AS CHAR)
	END AS "Cant. de ejemplares"
FROM especies ES
	LEFT JOIN ejemplares EJ ON EJ.id_especie=ES.id 
	LEFT JOIN estados_vitales VIT ON EJ.id_estado_vital=VIT.id
WHERE estado="vivo en pie"
GROUP BY ES.id;

/*Errores frecuentes
	LEFT JOIN INNER JOIN estados_vitales 
    no mostrar leyenda
    IFNULL(count(ES.id), "Sin ejemplares") count(EJ.id) devuelve 0 si no hay ejemplares
	COALESCE(count(ES.id), "Sin ejemplares") mismo caso 
 */


/*
f)(3 puntos) Informar las especies que tuvieron más de 100 reclamos en el último año, ordenado por cantidad de reclamos descendente.
|Nombre común |Nombre científico |Cant. de reclamos |
*/

SELECT 
	nombre_comun "Nombre común", 
	nombre_cientifico "Nombre científico", 
    count(REC.id) "Cant. de reclamos"
FROM especies ESP 
	JOIN ejemplares EJE ON ESP.id=EJE.id_especie
    JOIN reclamos REC ON EJE.id=REC.id_ejemplar
WHERE REC.fecha >= DATE_ADD(CURDATE(), INTERVAL -12 MONTH)
GROUP BY ESP.id, nombre_comun, nombre_cientifico
HAVING count(REC.id) > 100
ORDER BY 3 DESC;   

/*Errores frecuentes
	YEAR(CURDATE()) = YEAR(REC.fecha)  --> año calendario
    WHERE COUNT(R.id)  --> HAVING
    WHERE DATE_ADD(CURDATE(), INTERVAL -12 MONTH) con que atributo lo comparo?
*/
