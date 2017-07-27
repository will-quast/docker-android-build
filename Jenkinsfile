uacf_generic_pipeline {
    publish_branches = ['master']
    disable_test = true
    disable_appsec = true
    disable_publish = false

    images = [
        mmf_android_docker: [
            DOCKER_IMAGE_NAME: "uarun/android-sdk",
            DOCKER_CONTEXT_PATH: ".",
            DOCKER_FILE: "./Dockerfile",
            DOCKER_TAGS: "platform-24",
            SLAVE: 'android',
        ]
    ]
}

