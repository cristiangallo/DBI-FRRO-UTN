-- Practica Nº 5: Subconsultas, Tablas Temporales y Variables
-- Practica en Clase: 1 – 2 – 3 – 4 – 7 – 9 – 10 – 11 – 12 – 16
-- Práctica Complementaria: 5 – 6 – 8 – 13 – 14 – 15 – 17
-- BASE DE DATOS: AGENCIA_PERSONAL


-- 1 )¿Qué personas fueron contratadas por las mismas empresas que Stefanía Lopez?
-- |dni |apellido |nombre|
SELECT PER.dni, PER.apellido, PER.nombre 
	FROM `agencia_personal`.`personas` PER 
		INNER JOIN `agencia_personal`.`contratos` CON ON PER.dni=CON.dni 
	WHERE CON.cuit IN (
		SELECT CON.cuit 
			FROM `agencia_personal`.`personas` PER 
				INNER JOIN `agencia_personal`.`contratos` CON ON PER.dni=CON.dni
			WHERE CONCAT(nombre, " ", apellido) LIKE "Stefan_a Lopez"); 

-- 2) Encontrar a aquellos empleados que ganan menos que el máximo sueldo de los empleados
-- de Viejos Amigos.
-- |dni |nombre y apellidos |sueldo

# utilizando subconsultas
SELECT PER.dni, CONCAT(nombre, " ", apellido) "nombre y apellidos", sueldo
	FROM `agencia_personal`.`contratos` CON 
		INNER JOIN `agencia_personal`.`personas` PER ON CON.dni=PER.dni
	WHERE sueldo < (
		SELECT MAX(sueldo) 
			FROM `agencia_personal`.`contratos` CON 
				INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit=EMP.cuit
			WHERE EMP.razon_social = "Viejos Amigos");
# utilizando subconsultas

# utilizando variables
SET @MAX_SUELDO = (
		SELECT MAX(sueldo) 
			FROM `agencia_personal`.`contratos` CON 
				INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit=EMP.cuit
			WHERE EMP.razon_social = "Viejos Amigos");
SELECT PER.dni, CONCAT(nombre, " ", apellido) "nombre y apellidos", sueldo
	FROM `agencia_personal`.`contratos` CON 
		INNER JOIN `agencia_personal`.`personas` PER ON CON.dni=PER.dni
	WHERE sueldo < @MAX_SUELDO;
# utilizando variables

-- 3) Mostrar empresas contratantes y sus promedios de comisiones pagadas o a pagar, pero sólo
-- de aquellas cuyo promedio supere al promedio de Tráigame eso.
SELECT emp.cuit, emp.razon_social, AVG(importe_comision) "comisión Promedio "
	FROM `agencia_personal`.`comisiones` COM 
		INNER JOIN `agencia_personal`.`contratos` CON ON COM.nro_contrato=CON.nro_contrato 
        INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit=EMP.cuit
	GROUP BY emp.cuit
    HAVING AVG(importe_comision) > (
		SELECT AVG(importe_comision)
			FROM `agencia_personal`.`comisiones` COM 
				INNER JOIN `agencia_personal`.`contratos` CON ON COM.nro_contrato=CON.nro_contrato 
				INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit=EMP.cuit
			WHERE razon_social = "Tráigame eso");


-- 4) Seleccionar las comisiones pagadas que tengan un importe menor al promedio de todas las
-- comisiones(pagas y no pagas), mostrando razón social de la empresa contratante, mes
-- contrato, año contrato , nro. contrato, nombre y apellido del empleado.

SET @prom_comision=(SELECT AVG(importe_comision) FROM `agencia_personal`.`comisiones`);
SELECT EMP.razon_social "Razón social", mes_contrato "mes contrato", anio_contrato "año contrato",
	CON.nro_contrato "Nro contrato", CONCAT(nombre, " ", apellido) "Nombre y apellido"
	FROM `agencia_personal`.`comisiones` COM 
		INNER JOIN `agencia_personal`.`contratos` CON ON COM.nro_contrato=CON.nro_contrato
        INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit=EMP.cuit
        INNER JOIN `agencia_personal`.`personas` PER ON CON.dni=PER.dni
	WHERE fecha_pago IS NOT NULL and importe_comision < @prom_comision;


-- 5) Determinar las empresas que en promedio pagaron más comisiones 
-- que la comision promedio
SELECT AVG(sueldo) FROM `agencia_personal`.`contratos`;

SELECT emp.cuit, emp.razon_social, AVG(importe_comision) "Sueldo promedio"
	FROM `agencia_personal`.`empresas` emp
		INNER JOIN `agencia_personal`.`solicitudes_empresas` SE
			ON emp.cuit=SE.cuit
		INNER JOIN `agencia_personal`.`contratos` con 
			ON SE.cuit=con.cuit 
				and SE.cod_cargo=con.cod_cargo 
					and SE.fecha_solicitud=con.fecha_solicitud
		INNER JOIN `agencia_personal`.`comisiones` COM ON con.nro_contrato=COM.nro_contrato
	GROUP BY emp.cuit
    HAVING AVG(importe_comision) > (
		SELECT AVG(importe_comision) FROM `agencia_personal`.`comisiones`)
    ;


-- 6) Seleccionar los empleados que no tengan educación no formal o terciario.
-- |apellido |nombre   |
SELECT DISTINCT nombre, apellido   # duplicados porque tienen más de un titulos
	FROM `agencia_personal`.`personas` per 
		LEFT JOIN `agencia_personal`.`personas_titulos` pt ON per.dni=pt.dni
        # LEFT JOIN `agencia_personal`.`titulos` t ON pt.cod_titulo=t.cod_titulo
    WHERE pt.cod_titulo IN (
		SELECT cod_titulo FROM `agencia_personal`.`titulos`
			WHERE tipo_titulo NOT IN ("Educacion no formal", "Terciario")
    )
    ORDER BY apellido;
;

SELECT DISTINCT PER.apellido, PER.nombre 
	FROM `agencia_personal`.`personas` PER
		INNER JOIN `agencia_personal`.`personas_titulos` PT ON PER.dni = PT.dni
        INNER JOIN `agencia_personal`.`titulos` TIT ON PT.cod_titulo = TIT.cod_titulo
	WHERE tipo_titulo NOT IN ("Educacion no formal", "Terciario");

SELECT 
  P.apellido,
  P.nombre
FROM personas P
WHERE P.dni NOT IN (
  SELECT PT.dni
  FROM personas_titulos PT
  INNER JOIN titulos T ON PT.cod_titulo = T.cod_titulo
  WHERE T.tipo_titulo IN ('Educacion no formal', 'Terciario'));

-- 7) Mostrar los empleados cuyo salario supere al promedio de sueldo de la empresa que los
-- contrató.
-- |cuit |dni |sueldo |prom

-- Error Code: 1050. Table 'tt_sueldo_prom_emp' already exists
DROP TEMPORARY TABLE IF EXISTS tt_sueldo_prom_emp;
CREATE TEMPORARY TABLE tt_sueldo_prom_emp(
	SELECT cuit, AVG(sueldo) "sueldo_promedio"
		FROM `agencia_personal`.`contratos`
		GROUP BY cuit);

SELECT * FROM tt_sueldo_prom_emp;
DESCRIBE tt_sueldo_prom_emp;

SELECT tt_sp.cuit "cuit", PER.dni, concat(nombre, " ", apellido) "nombre y apellido",
	sueldo, tt_sp.sueldo_promedio "sueldo promedio"
	FROM `agencia_personal`.`personas` PER 
		INNER JOIN `agencia_personal`.`contratos` CON
			ON PER.dni=CON.dni
		INNER JOIN tt_sueldo_prom_emp tt_sp ON CON.cuit=tt_sp.cuit
	where sueldo > tt_sp.sueldo_promedio
;
DROP TEMPORARY TABLE tt_sueldo_prom_emp;

-- 9 – 10 – 11 – 12 – 16
-- 9) Alumnos que se hayan inscripto a más cursos que Antoine de Saint-Exupery. Mostrar
-- todos los datos de los alumnos, la cantidad de cursos a la que se inscribió y cuantas
-- veces más que Antoine de Saint-Exupery.
-- |dni |nombre|apellido |direccion |email |te |count(*) count(*)- @cant)

-- 11) Indicar el valor actual de los planes de Capacitación
-- nom_plan fecha_desde_plan valor_plan


-- 12) Plan de capacitacion mas barato. Indicar los datos del plan de capacitacion y el valor actual
-- nom_plan desc_plan hs modalidad valor_plan

-- 16)Para conocer la disponibilidad de lugar en los cursos que empiezan en abril para
-- lanzar una campaña se desea conocer la cantidad de alumnos inscriptos a los cursos
-- que comienzan a partir del 1/04/2014 indicando: Plan de Capacitación, curso, fecha de
-- inicio, salón, cantidad de alumnos inscriptos y diferencia con el cupo de alumnos
-- registrado para el curso que tengan al más del 80% de lugares disponibles respecto del
-- cupo.
-- Ayuda: tener en cuenta el uso de los paréntesis y la precedencia de los operadores
-- matemáticos.
-- nro_curso fecha_ini salon cupo count( dni ) ( cupo - count( dni ) )


