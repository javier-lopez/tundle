## Style guideline

- Avoid syntax or semantics unique to bash, zsh, or any other specific shell, eg:
    - array contructs
    - parameter subtitution; `<()` or `>()`
    - `{a,b,c}` or `{1..10}`
    - the `function` keyword at the beginning of a function
    - C-like for loops, `for ((i=0; i<3; i++))`
- Avoid `basename`, use `expr` or parameter expansion (${variable##\*/}) instead
- Avoid parsing `ls` output
- Use `=` over `==`
- Use `case` over `test` or `[` for regex
- Use `[` or `test` over `[[`
- Use `command -v` or `type` over `which`
- Use parameter expansion over `awk`,`cut` or `basename` on simple strings
- Use `awk` over `sed`, `grep`, `cut`, `sort`, `tr` or `unique`
- Use `/bin/sh` over `/bin/bash` or `/usr/bin/env bash`
- Use `$(foo)` over `\`foo\``
- Use `$((${i}+1))` over `$(expr "${i}" + 1)`
- Use `:` as a sed separator, eg: `sed -e 's:foo:bar:'`
- Use lowercase over uppercase, except in vars users will interact with, eg: `GLOBAL_VAR_PROGRAM`
- Use spaces over tabs
- Avoid forking or using extra pipes when not necessary, eg,

  **Bad**
   ```sh
   is_directory()
   {
      [ -d "${1}" ]
   }

   sed 's:foo:bar:g' | sed 's:more:less:g'
   if is_directory "${directory}"
      printf "%s\\n" "${directory} is a directory"
   fi
   ```

  **Good**
   ```sh
   sed 's:foo:bar:g;s:more:less:g'
   if [ -d "${directory}" ]
      printf "%s\\n" "${directory} is a directory"
   fi
   [ -d "${directory}" ] && printf "%s\\n" "${directory} is a directory"
   ```

- Use braces around multiple variables, eg,

  **Bad**
   ```sh
   var="$foo"
   var="$foo$bar"
   var="/path/$foo.suffix"
   ```

  **Good**
   ```sh
   var="${foo}"
   var="${foo}${bar}"
   var="/path/${foo}.suffix"
   ```

- Use quotes when assigning values to variables, use single quotes when absolutely necesary

  **Bad**
   ```sh
   foo=bar
   bar=${foo}
   ```

  **Good**
   ```sh
   foo="bar"
   bar="${foo}"
   ```

- Define functions with an underscore prefix, eg,

  **Bad**
   ```sh
   encode64()
   {
       steps
   }
   ```

  **Good**
   ```sh
   _encode64()
   {
       steps
   }
   ```

- Prefer minimal style

  **Bad**
   ```sh
   if foo
   then
       bar
   fi

   if [ -z "${foo}" ]; then
       cmd
   fi

   if [ -z "${foo}" ]; then
       cmd
   else
       other_cmd
   fi

   _foo()
   {
       _foo__first_argument="${1}"
       printf "%s\\n" "${_foo__first_argument}"
   }
   ```

  **Good**
   ```sh
   if foo; then
       bar
   fi

   [ -z "${foo}" ] && cmd

   [ -z "${foo}" ] && cmd || other_cmd

   _foo()
   {
       printf "%s\\n" "${1}"
   }
   ```
- Local variables should be named unique after their function name (or an abbreviation of it) and separated by doble underscore, avoid `local`

  **Bad**
   ```sh
   _foo()
   {
       local basename="${1##*/}"
   }

   _foo_bar()
   {
       local basename="${1##*/}"
   }
   ```

  **Good**
   ```sh
   _foo()
   {
       _foo__basename="${1##*/}"
   }

   _foo_bar()
   {
       _fbar__basename="${1##*/}"
   }
   ```

- Use `printf` over `echo` (specially when echoing ${vars})

  **Bad**
   ```sh
   echo "${foo}"
   ```

  **Good**
   ```sh
   printf "%s\\n" "${foo}"
   ```
- Avoid fixed paths in commands:

  **Bad**
   ```sh
   [ -f /usr/bin/ps ] && /usr/bin/ps
   ```

  **Good**
   ```sh
   if command -v "ps" > /dev/null; then
       $(command -v "ps")
   fi
   ```

  **Better**
   ```sh
   [ -f "$(command -v "mplayer")" ] && $(command -v "mplayer")
   ```
- Avoid -q in grep, git and other command, redirect stdout to /dev/null instead

   **Bad**
   ```sh
   grep -qs pattern file && return 0
   ```

   **Good**
   ```sh
   grep pattern file >/dev/null && return 0
   ```
- Do NOT write to the file system, use vars or pipes instead

  **Bad**
   ```sh
   grep pattern file > /tmp/grep.output
   ```

  **Good**
   ```sh
   grep_output="$(grep pattern file)"
   ```
- Use `||` and `&&` over `-a` and `-o`

  **Bad**
   ```sh
   if [ "-d" = "${1}" -o "--delete" = "${1}" ]; then
       foo
   fi
   ```

  **Good**
   ```sh
   if [ "-d" = "${1}" ] || [ "--delete" = "${1}" ]; then
       foo
   fi
   ```
