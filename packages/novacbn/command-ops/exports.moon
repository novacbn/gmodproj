CommandOps  = dependency "novacbn/command-ops/CommandOps"
Command     = dependency "novacbn/command-ops/Command"
Options     = dependency "novacbn/command-ops/Options"

with exports
    .Command        = Command.Command
    .CommandOps     = CommandOps.CommandOps
    .Options        = Options.Options