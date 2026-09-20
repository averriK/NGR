## Objective
Etapa 1 del propietario: `ngr` reemplaza a qrt y psha, hidratando desde una ubicación arbitraria, sin modificar la superficie de producción de la librería fuera de un plan SoT. Cerrada. La etapa 2 (gráficos y tablas por CLI para agentes con skills en `skill/`) no empezó.

## Rulings
- «la libreria NGR es una libreria en produccon. podemos agregar cosas pero no podemo smodificar nada sin un plan SoT.»
- Manifiesto único `manifest.json`; el parser vive en `cli/main.R` llamando solo exports; el oráculo de NGR es qrt instalado.
- Git: «si, permiso permanente para commit y push»; commit en `dev` y `main` por avance directo.
- Instalador: «sudo bash install/install.sh», sin argumentos — el prefijo `/usr/local` y la librería `R_LIBS_USER` son sus defaults (`install/install.sh:20,130`). Un producto **reporta** defectos del instalador y no implementa su política.
- Datos: los parámetros científicos salen del contrato del productor que los consume, sin otro lugar; `DaH.gmdp` a `newmark.json`; `PSA_Units` a `params.yml`; `data.R` se retira. Sin modo legado: contrato ausente = error que lo nombra.
- Alcance 2026-09-20: retirado de los siete proyectos con `hazard.json` y de los tres sin contrato; el `GMPETable` que falta en AR-M2V4D lo genera oqt-V2.
- Ajeno, no se toca: `dev/plan/cli-fusion/` y `dev/docs/`.
- Rutas aplicables: code, sot, r, git; bash y python según archivo.

## Evidence and no-repeat
- Historia de esta cadena en Git: plan, handoffs, propuestas y evidencia congelada de R1–R9, L2–L3 y T1–T9 vivieron en `dev/plan/cli-repair/` y `dev/SoT/cli-repair/` hasta `02ec950`, y se retiraron del árbol por orden del propietario. Se recuperan con `git log --diff-filter=D -- dev/SoT/cli-repair`.
- Etapa 1 en `origin/main`: R1 hidratación arbitraria `3f27df4`, R2 masters `a5e9788`, R4 destinos `277ec75`, R5 revisión sin git `8a08f43`, R6 parser en `cli/main.R` `d8c9159`, R8 rastros de qrt `acd0d00`, R9 convivencia de manifiestos `15d4fbf`, L2 `R CMD check --as-cran` del tarball exacto `438a375`, kit de familia `5878651`, instalador AOM 0.2.0 `18b6d91`.
- Aceptación real: deck `sha` de AR-S2L1W byte-idéntico entre qrt+psha y ngr salvo sello e ids de widget. Cobertura de psha comprobada el 2026-09-20 con el ngr instalado: sus cinco comandos cubiertos y los 16 componentes que enumera su `pull --help` presentes tras hidratar desde `libraries/reports/sha`, con `status --check` exit 0 y `doctor` passed.
- El scaffold lee los datos por contrato (`reports` dev/main `6672b0d`): falla nombrando contrato, clave y ruta; una raíz declarada sin producto de su productor falla; una tabla que el proyecto nunca produjo queda ausente.
- `pull` protege `.git .ngr oq gmsp data run manifest.json qrt.manifest.json hazard.json newmark.json` y, dinámicamente, las raíces que declaren los contratos del proyecto (`lib/R/resources.R`).
- Los 14 contratos de los 7 proyectos están publicados y validados con las librerías publicadas (hazard 0.2.0, newmark 1.7.1): `hazard process --dry-run` exit 0 en los 7 y `newmark process --steps dn,kmax --dry-run` exit 0 en los 6 con productos.
- Condición de entorno: `cli/tests` exige `/usr/local/bin` delante de `/usr/bin` en PATH y que exista `NGR_TEST_ROOT`.
- Errores propios de esta cadena, para no repetirlos: afirmar una rama no ejecutada (sudo), listar `Vs30.gmdp` como clave sin ver que `global.R:23` la deriva sin guarda, cambiar la forma de `Dn_weights` llamándola defecto sin leer cómo parsea el CLI, comprobar LFS por `.git/config` en vez de `git config --get`, y commitear en un repo con el índice de otro agente ocupado.

## Effects
- Instalado en `/usr/local` el 2026-09-20 desde `b28bce9`: recibo esquema 4 con 408 archivos, lanzador que resuelve R con `resolve_rscript` y conserva `NGR_COMMAND_PATH`, sin el `RSCRIPT` congelado anterior. El defecto del lanzador que reporté quedó cerrado: con señuelo primero en PATH y con `env -i PATH=/usr/bin:/bin`, exit 0 donde antes daba 99 y 127.
- El `--help` corregido (`12a80c6`) **no** está instalado: la copia de `/usr/local` viene de `b28bce9` y emite la prosa vieja hasta la próxima reinstalación.
- Reporte y propuesta para el contrato CLI de AOM en `AOM/dev/REPORTE-NGR-HELP-CONTAMINADO-20260920.md`: el help contaminado, ya corregido, y el hallazgo de `--from`, que acepta un identificador reservado o una ruta y tapa un manifiesto local llamado `ngr` sin avisar (`cli/main.R:125`). No se cambia: superficie pública, la forma la fija el §5.
- En AR-M2V4D quedaron 20 tablas en git plano mientras su `.gitattributes` (`7cee9f5`, mío) declara LFS; lo commiteé con la migración de oqt-V2 en el índice y se lo reporté para que lo revierta si interfiere.

## Blocker
none

## Next
NEXT-ID {"action":"Esperar instrucción del propietario. De su lado: reinstalar para que el --help corregido llegue a /usr/local; qué hacer con las 20 tablas de AR-M2V4D en git plano frente a su .gitattributes; y su lectura del 18,8% de filas de kmax de AR-M2V4D que extrapolan fuera del soporte muestreado. De AOM: la forma de ayuda y de opciones del §5, que fija si --from puede aceptar dos clases de valor. De oqt-V2: el GMPETable de AR-M2V4D y el aviso de mudanza cerrada para comprobar los lectores del informe contra el árbol nuevo.","id":"cli-repair-await-owner-20260920"}

## Status
ACTIVE
