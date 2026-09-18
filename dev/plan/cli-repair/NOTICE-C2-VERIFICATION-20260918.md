# C2 verificado: `ngr` instalado en `/usr/local` (2026-09-18 14:00 -03)

Autor: sesión NGR-V2. Destinatarios: propietario y agente del instalador.
Solo hechos observados; la corrida del propietario está archivada en
`/Users/averrik/Cloud/github/libraries/NGR/dev/SoT/cli-repair/sudo-install-run-20260918.log`.

## 1. Resultado: la instalación funciona

| Comprobación | Observado |
| --- | --- |
| `sudo bash install/install.sh` | 5 etapas `[OK]`; root escribió `/usr/local`, todo R corrió como `averrik`; sin pedir contraseña dos veces |
| `/usr/local/bin/ngr --version` (como `averrik`) | `ngr 0.2.0-dev` / `package: NGR 0.4.0` / `library: /Users/averrik/Library/R/arm64/4.6/library/NGR` / `cli: /usr/local/libexec/ngr/main.R` / `build: backup-before-typewriter-height-164-g36e7182-dirty`; exit 0 |
| Recibo `/usr/local/libexec/ngr/install.json` | `product ngr-cli`, `schema 4`, 405 archivos: 405 presentes, 405 md5 iguales; `kit` 17 archivos, md5 iguales al canónico `~/github/agents/install/` y a `NGR/install/` en ese momento; `source.commit 36e7182…`, `dirty true` |
| `BUILD_INFO` | presente en `/usr/local/libexec/ngr/BUILD_INFO` y en `/usr/local/libexec/ngr/scaffold/BUILD_INFO` (idénticos); la librería lo lee junto a `scaffold/manifest.json` |
| Proyecto scratch | `ngr pull --from ngr` → «complete: 389 resource contributions»; `ngr status` todo `equal`; `ngr doctor` → «declared checks passed»; el `manifest.json` del proyecto apunta a `/usr/local/libexec/ngr/scaffold/manifest.json` |
| Efectos colaterales | 0 archivos de root en `~/Library/R/arm64/4.6/library`; sin restos `/tmp/NGR-cli.*` |

## 2. Hallazgos para el agente del instalador (no corregidos por mí; `install/` es suyo)

1. **Se instaló desde un árbol sucio y eso sella todo como DRAFT.** `install/` sigue sin commitear
   (13 modificados + 4 nuevos sobre `36e7182`). `BUILD_INFO` quedó con
   `git_describe=…-g36e7182-dirty`; `lib/R/resources.R:160-169` (`.recordedRevision`) marca `dirty`
   cuando `git_describe` termina en `-dirty`, los 389 recibos del proyecto scratch salieron
   `dirty: True`, y `lib/R/quartoRenderStamp.R:44-56` agrega `· DRAFT` a todo documento con una
   revisión sucia. Con esta instalación **todos los renders saldrán `· DRAFT`**. Remedio:
   commitear y publicar `install/` y reinstalar desde árbol limpio.
2. **`dirty` se calcula sobre todo el repositorio, no sobre lo que se instala.**
   `install/cli/manage.R:296-300`: `git describe --tags --always --dirty` y `git status --porcelain`
   sin rutas. En NGR hay un archivo ajeno con seguimiento modificado
   (`dev/plan/cli-fusion/STATE.md`): aun con `install/` commiteado, `describe` seguirá diciendo
   `-dirty` y los renders seguirán en DRAFT. El clásico psha limita el chequeo a lo instalado
   (`tools/psha/install/install.sh:175`: `git status --porcelain --untracked-files=all -- bin scaffold`).
   Decidir: limitar a las rutas del manifiesto, o exigir árbol limpio como precondición declarada.
3. **Los archivos instalados quedaron a nombre de `averrik`, no de root.** En
   `/usr/local/libexec/ngr`: 126 directorios de root y 403 archivos de `averrik`; `/usr/local/bin/ngr`
   es `averrik:wheel 0755`. En los clásicos y en la instalación de gmsp de las 08:27 los archivos
   son `root:wheel`. Origen probable (sin verificar): `publish.sh` copia como root preservando el
   dueño del staging preparado por el usuario. Un ejecutable en `/usr/local/bin` modificable sin sudo
   se aparta del modelo clásico.
4. **Cosmético:** `build:` muestra la etiqueta git más cercana del repo NGR
   (`backup-before-typewriter-height-164-g36e7182`), que es lo que devuelve `git describe --tags`;
   el `git_commit` del `BUILD_INFO` es correcto.
5. Sigue vigente del handoff de pendientes: sin sudo y sin `--prefix`, el instalador corta con un
   error crudo de R en vez de `[ERROR] … run: sudo bash install/install.sh`.

## 3. Lo que sigue

- Agente del instalador: hallazgos 1–3 y commit de `install/`.
- Propietario: reinstalar (`sudo bash install/install.sh`) cuando el árbol esté limpio; C3 (fósil
  NGR 0.3.10 en la librería de root) sigue pendiente.
- Agente de NGR: tras la reinstalación, verificar `build:` sin `-dirty` y un render de prueba sin
  `· DRAFT` (Next en `STATE.md`).
