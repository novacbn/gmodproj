adapters = with {}
    .FileSystemAdapter = dependency("novacbn/luvit-extras/adapters/FileSystemAdapter").FileSystemAdapter

with exports
    .adapters   = adapters
    .crypto     = dependency "novacbn/luvit-extras/crypto"
    .fs         = dependency "novacbn/luvit-extras/fs"
    .process    = dependency "novacbn/luvit-extras/process"
    .vfs        = dependency "novacbn/luvit-extras/vfs"