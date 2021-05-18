# parse_git_dirty and prompt_git are modified from
# https://github.com/oh-my-fish/theme-agnoster/blob/master/functions/fish_prompt.fish

function parse_git_dirty
    set -l submodule_syntax
    set submodule_syntax "--ignore-submodules=dirty"
    set untracked_syntax "--untracked-files=normal"
    set git_dirty (command git status --porcelain $submodule_syntax $untracked_syntax 2> /dev/null)
    if [ -n "$git_dirty" ]
        echo -n "dirty"
    end
end

function prompt_git -d "Display the current git state"
    set -l ref
    set -l dirty
    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set dirty (parse_git_dirty)
        set ref (command git symbolic-ref HEAD 2> /dev/null)
        if [ $status -gt 0 ]
            set -l branch (command git show-ref --head -s --abbrev |head -n1 2> /dev/null)
            set ref " $branch "
        end
        set branch_symbol \uE0A0
        set -l branch (echo $ref | sed  "s-refs/heads/-$branch_symbol -")
        
        # there is a question mark at the start for some reason
        set -l branch (string sub --start=2 $branch)
        set -l branch (string trim $branch)
        
        if [ "$dirty" != "" ]
            set_color black -b yellow
        else
            set_color black -b green
        end
        
        echo -n " $branch "
    end
end

function fish_prompt
    set -l last_status $status
    set -l cwd (prompt_pwd)

    if not test $last_status -eq 0
        set_color black -b yellow
        echo -n " ! "
        set_color normal
    end

    # Display current path
    set_color black -b blue
    echo -n " $cwd "

    set git_status (prompt_git)
    if [ "$git_status" != "" ]
        echo -n "$git_status"
    end

    set_color normal
    echo -n '  '
end
