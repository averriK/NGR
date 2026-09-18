# Sello DRAFT por suciedad ajena y archivos sin dueño root (2026-09-18) — RESUELTOS

Detectados al verificar la primera instalación `sudo` real del kit en NGR
(`/usr/local`, recibo esquema 4 del 2026-09-18 13:59 -03; hallazgos 2 y 3 de
`libraries/NGR/dev/plan/cli-repair/NOTICE-C2-VERIFICATION-20260918.md`).
Corregidos en este kit canónico el 2026-09-18 (~14:25) y verificados en NGR
con el oráculo del kit y una instalación de producto en prefijo scratch.

## Hallazgo 2: `dirty` medido sobre todo el repo — `install/cli/manage.R`

`git describe --tags --always --dirty` y `git status --porcelain` sin rutas:
cualquier archivo ajeno modificado (planes, documentación, un `STATE.md` de
otra cadena de trabajo) sellaba `git_describe` con `-dirty`, y la librería
marca todo render como `· DRAFT`. Corrección: `describe` sin `--dirty` y
`status --porcelain -- cli install lib` (las fuentes del payload que existan
en el repo); el sufijo `-dirty` se agrega solo cuando ese alcance está sucio.
Paridad con el clásico psha (`git status --porcelain -- bin scaffold`).

## Hallazgo 3: archivos publicados a nombre del usuario — `install/cli/publish.sh`

El staging lo prepara R como el usuario invocante y `publish_cli` lo movía con
`cp -pP`/`mv` preservando dueño: bajo `sudo`, los ejecutables de `/usr/local`
quedaban modificables sin sudo, fuera del modelo clásico (`root:wheel`).
Corrección: tras cada `mv`, si `id -u` es 0, `chown 0:0` del archivo publicado.
Sin elevación (pruebas, `--prefix` de usuario) no cambia nada.

## Acción para los repos de la familia

Cualquier `install/` copiado de este canónico antes del 2026-09-18 ~14:25
arrastra ambos hallazgos: re-sincronizar byte a byte desde este directorio y
reinstalar con `sudo bash install/install.sh` desde un árbol cuyas rutas
`cli/ install/ lib/` estén limpias; los archivos instalados quedan de root y
`build:` sin `-dirty`.
