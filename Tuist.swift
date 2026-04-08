import ProjectDescription

let tuist = Tuist(
    fullHandle: "__FULL_HANDLE__",
    cache: .cache(upload: true),
    project: .tuist(
        generationOptions: .options(
            disableSandbox: false,
            enableCaching: true
        ),
        cacheOptions: .options(
            profiles: .profiles(default: .onlyExternal)
        )
    )
)
