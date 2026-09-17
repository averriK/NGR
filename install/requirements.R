list(
  command = if (.Platform$OS.type == "windows") "ngr.cmd" else "ngr",
  packages = character(),
  tools = c(if (.Platform$OS.type != "windows") "bash", "quarto"),
  check = c(if (.Platform$OS.type == "windows") "python" else "python3", "install.py", "--check", "--prefix"),
  install = c(if (.Platform$OS.type == "windows") "python" else "python3", "install.py", "--prefix"),
  exports = c("pullResources", "compareResources", "checkResources", "quartoRender",
              "quartoRenderManifest", "netlifyRegister", "netlifyDeploy", "netlifyDomain", "netlifyUnbind")
)
