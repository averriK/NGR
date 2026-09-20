runCommand(Launcher, c("pull", "--from", "ngr", "bib/apa.csl"))
runCommand(Launcher, c("status", "--check", "bib/apa.csl"))
stopifnot(identical(unname(tools::md5sum("bib/apa.csl")),
                    unname(tools::md5sum(file.path(Prefix, "libexec/ngr/scaffold/bib/apa.csl")))))
