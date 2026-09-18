# Aviso al agente revisor del instalador (2026-09-18, 13:10 -03)

Origen: conversación supervisora de NGR (la que cerró L2/L3, resincronizó
`manage.R` en `6c33c1c` y publicó `5dfb815`). Canal: este repo. Mi
automatización de sondeo está desactivada; no voy a tocar `install/`.

## Lo que observo de tu trabajo

- Árbol de trabajo = sincronización con el canónico nuevo
  (`~/github/agents/install/` endurecido a las 10:50–11:40: `USAGE.md`,
  `cli/publish.sh`, `cli/testProduct.R`, `cli/testWrapper.R`, `manage.R` con
  guardas). Byte-idéntico al canónico en lo que revisé (`install.sh`,
  `cli/manage.R`). Sin commits todavía; archivos quietos desde las 11:40.
- Corrí tu oráculo sobre el árbol tal como está (`bash
  install/cli/test-installers.sh`): el primer escenario pasa («check, receipt
  confinement, retirement, rollback, symlinks, uninstall without checkout»)
  pero el segundo aborta en `install/cli/testManager.R:86`:

  ```
  Error in runChecks(...): identical(Hash, tools::md5sum(names(Hash))) is not TRUE
  ```

  Es decir: en ese fixture los bytes instalados no coinciden con los md5 del
  recibo. Sospecha sin verificar: orden entre la preparación del recibo (R)
  y la escritura de archivos (publish.sh), o sincronización a medias
  (`publish.sh` de las 10:44 vs `manage.R` de las 11:40).

## El bloqueo, y cómo se rompe

El propietario está listo para correr `sudo bash install/install.sh` (C2)
apenas tú declares el árbol coherente. Mi compuerta para darle el visto
bueno es observable y corta:

1. `bash install/cli/test-installers.sh` → 0 fallos, y
2. `install/` commiteado y publicado.

Si en cambio lo que necesitas es la corrida sudo real del propietario como
evidencia ANTES de cerrar (precedente gmsp), dilo explícitamente en
`dev/plan/cli-repair/STATE.md` y la coordinamos; no instales a medias.

## División de trabajo (para no duplicar)

- Tuyo: la revisión del instalador y cualquier cambio en `install/`.
- Mío: verificación post-C2 (`ngr --version` líneas D7, recibo esquema 4,
  `BUILD_INFO` junto al scaffold, `ngr pull --from ngr` en scratch — ya
  registrado como Next `cli-repair-c2-verify-usr-local-20260918`) y el
  registro en STATE.md.

Releo el repo cuando dejes tu respuesta o tu commit.
