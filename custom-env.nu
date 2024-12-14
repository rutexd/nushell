use std "path add"

# alias kill = ^taskkill /f /im
# alias pkill = ^taskkill /f /im
alias cwd = pwd
alias mc = portablemc
alias reboot = shutdown /g /t 1

path add { windows: "C:\\sdk\\maven\\bin" }
path add { windows: "C:\\Program Files\\Yggdrasil\\" }
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

def create-venv [venvName?: string] {
  mut name = ".venv";
  if $venvName != null {
    $name = $venvName
  }

  if not ($name | path exists) {
    python -m venv $name
  } else {
    echo $"Venv already exists at '($name)'"
  }
}

def run-with-build-tools [blk: string, path: string = "C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\VC\\Auxiliary\\Build\\vcvars64.bat"] {
  let cmd = $blk | str replace "\"" "`"

  if not ($path | path exists) {
    echo $"Build tools not found at '($path)'"
  } else {
    ^cmd /c ($path) ^&^& $cmd
  }
}

def activate-build-tools [] {
  run-with-build-tools "nu"
}

def activate-venv [venvName?: string] {
  mut name = ".venv";
  if $venvName != null {
    $name = $venvName
  }

  let pathString = $"($name)\\Scripts\\activate"
  let totalCmd = $"($pathString) && nu"

  if ($pathString | path exists) {
    ^cmd /c $totalCmd
  } else {
    echo $"No venv found at ($pathString)"
  }
}

def copy-to-clipboard [text: string] {
  $text | clip
}

# windows terminal tab color
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


def processes [] {
  ps | get name
}

def kill [process: string@processes] {
  ^taskkill /f /im $process
}

def download [url: string, savePath?: string] {
  mut path = $url | path basename
  if $savePath != null {
    $path = $savePath
  }

  if not ($path | path exists) {
    echo $"Downloading '($url)' to '($path)'"
    http get $url | save $path -p    
  } else {
    echo $"File already exists at '($path)'"
  }
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


# module python {
#   # find current python path 
#   def findPython [] {
#     let pythonPath = ((which python).path | get 0)
#     let folder = (pythonPath | path dirname)
#     echo $"Python path: ($pythonPath)"
#   }
# }

module java {
  def --env export_java [home: string] {
    load-env {
      JAVA_HOME: $home
      JAVA_BIN: ($home | path join 'bin' | path join 'java.exe')
      Path: ($env.Path | split row (char esep) | prepend $home | prepend ($home | path join 'bin') | str join (char esep))
    }
  }

  export def --env java-8 [] {
    export_java "C:\\Program Files\\Java\\jre-8"
    print "Java 8 activated"
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

  export def --env java-21 [] {
    export_java "C:\\Program Files\\Java\\jdk-21\\"
    print "Java 21 activated"
  }

  export def --env java-23-graal [] {
    export_java "C:\\sdk\\graalvm-jdk-23+37.1"
    print "Java 23 Graal activated"
  }
}