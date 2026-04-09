import ProjectDescription

let tuist = Tuist(
    __TUIST_FULL_HANDLE_ARGUMENT__
    cache: .cache(upload: __TUIST_CACHE_UPLOAD__),
    project: .tuist(
        generationOptions: .options(
            disableSandbox: false,
            enableCaching: __TUIST_ENABLE_CACHING__
        ),
        cacheOptions: .options(
            profiles: .profiles(default: .onlyExternal)
        )
    )
)
