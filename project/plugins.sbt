// +------------------------------------------------------------------------------------+
// | SBT Eclipse (https://github.com/typesafehub/sbteclipse)                            |
// | Creates .project and .classpath files for easy Eclipse project imports             |
// |                                                                                    |
// | See also: Eclipse downloads (http://www.eclipse.org/downloads/)                    |
// | See also: Scala IDE downloads (http://download.scala-ide.org/)                     |
// +------------------------------------------------------------------------------------+

resolvers += Classpaths.typesafeResolver

addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse" % "1.4.0")

// +-------------------------------------------------------------------------------------+
// | XSBT Web plugin (https://github.com/siasia/xsbt-web-plugin)                         |
// | Implements SBT 0.7.x Web project actions: "jetty-run" -> "container:start", etc ... |
// +-------------------------------------------------------------------------------------+

resolvers += "Siasia repo" at "http://siasia.github.com/maven2"

libraryDependencies <+= sbtVersion(v => "com.github.siasia" %% "xsbt-web-plugin" % (v+"-0.2.4"))

// +------------------------------------------------------------------------------------+
// | Proguard plugin (https://github.com/siasia/xsbt-proguard-plugin)                   |
// | Optimizes bytecode and shrinks jar releases by removing unreferenced entities.     |
// |                                                                                    |
// | See also: Proguard homepage (http://proguard.sourceforge.net/)                     |
// +------------------------------------------------------------------------------------+

// (repository already added above)
// resolvers += "Siasia repo" at "http://siasia.github.com/maven2"

addSbtPlugin("com.github.siasia" % "xsbt-proguard-plugin" % "0.1")

// +------------------------------------------------------------------------------------+
// | CoffeeScripted SBT (https://github.com/softprops/coffeescripted-sbt)               |
// | Automates "compilation" of coffeescript files (/src/main/*.coffee) into javascript |
// |                                                                                    |
// | See also: Coffeescript reference (http://jashkenas.github.com/coffee-script/)      |
// +------------------------------------------------------------------------------------+

resolvers += "less is" at "http://repo.lessis.me"

addSbtPlugin("me.lessis" % "coffeescripted-sbt" % "0.1.5")

// +------------------------------------------------------------------------------------+
// | Less SBT (https://github.com/softprops/less-sbt)                                   |
// | Automates "compilation" of less files (/src/main/*.less) into css                  |
// |                                                                                    |
// | See also: LESS reference (http://lesscss.org/)                                     |
// +------------------------------------------------------------------------------------+

// (repository already added above)
// resolvers += "less is" at "http://repo.lessis.me"

addSbtPlugin("me.lessis" % "less-sbt" % "0.1.0")
