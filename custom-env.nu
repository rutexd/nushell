use std "path add"

alias kill = ^taskkill /f /im
alias pkill = ^taskkill /f /im
alias cwd = pwd
alias mc = portablemc
alias reboot = shutdown /g /t 1

# path add { windows: "" }

$env.EDITOR = "code"

def open-custom-scripts-dir [] {
  code ($nu.env-path | path dirname | path join "scripts")
}


def run-java [home: string, args: closure] {
  with-env {
    JAVA_HOME: $home
    JAVA_BIN: ($home | path join 'bin' | path join 'java.exe')
    Path: ($env.Path | split row (char esep) | prepend $home | prepend ($home | path join 'bin') | str join (char esep))
  } {
    do $args
  }
}

def create-venv [] {
  python -m venv .venv 
}

def run-with-build-tools [blk: string, path: string = "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\BuildTools\\VC\\Auxiliary\\Build\\vcvars64.bat"] {
  # remove all " from the path and replace with `
  let cmd = $blk | str replace "\"" "`"
  ^cmd /c ($path) ^&^& $cmd
}

def activate-build-tools [] {
  run-with-build-tools "nu"
}

def activate-venv [p: string = ".\\.venv\\Scripts\\activate"] {
  cmd /c ".\\.venv\\Scripts\\activate & nu"
}

def copy-to-clipboard [text: string] {
  $text | clip
}

def set-color [idx: int] {
  ansi -e ( ["2;15;", ($idx | into string), (",|") ] | str join )
}

def uptime [] { sys host | get uptime }

def free [] { sys mem }

def lsg [] { ls | sort-by type name -i | grid -c | str trim }

def config-backup [dir: string = ($nu.home-path | path join "AppData" "Roaming" "nushell" "backup")] {
  let date: string = (date now | format date "%Y_%m_%d_%H_%M_%S")

  let envFileName = $"env-($date).nu"
  let configFileName = $"config-($date).nu"

  let envPath = ($dir | path join $envFileName)
  let configPath = ($dir | path join $configFileName)

  # Ensure the backup directory exists
  mkdir $dir

  cp $nu.env-path $envPath
  cp $nu.config-path $configPath

  print $"Backup created in ($dir)"
}


def close-sleep [] {
  powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
  powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1
  powercfg /S SCHEME_CURRENT
  echo "Sleep on lid close."
}

def close-sleep-not [] {
  powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
  powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
  powercfg /S SCHEME_CURRENT
  echo "Do nothing on lid close."
}


module java {
  def --env export_java [home: string] {
    load-env {
      JAVA_HOME: $home
      JAVA_BIN: ($home | path join 'bin' | path join 'java.exe')
      Path: ($env.Path | split row (char esep) | prepend $home | prepend ($home | path join 'bin') | str join (char esep))
    }
  }

  export def --env java-11 [] {
    export_java "C:\\Program Files\\Java\\jdk-11.0.15"
    print "Java 11 activated"
  }

  export def --env java-17 [] {
    export_java "C:\\Program Files\\Java\\jdk-17"
    print "Java 17 activated"
  }

  export def --env java-19 [] {
    export_java "C:\\Program Files\\Java\\jdk-19"
    print "Java 19 activated"
  }

  export def --env java-23-graal [] {
    export_java "C:\\sdk\\graalvm-jdk-23+37.1"
    print "Java 23 Graal activated"
  }

}