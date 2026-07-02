allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Workaround: the vosk_flutter_2 plugin (pub.dev, last published for AGP 7.x)
// only declares `package="org.vosk.vosk_flutter"` in its AndroidManifest.xml
// and has no `namespace` in its own android/build.gradle. AGP 8+ requires
// `namespace` to be set explicitly and no longer falls back to the manifest
// `package` attribute, so the module fails to configure without this.
// Backfill it here; this is a no-op once upstream adds `namespace` itself.
subprojects {
    afterEvaluate {
        if (project.name == "vosk_flutter_2") {
            project.extensions.findByName("android")?.withGroovyBuilder {
                setProperty("namespace", "org.vosk.vosk_flutter")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
