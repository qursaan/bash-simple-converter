#!/usr/bin/env bash
echo "Welcome to the Simple converter!"
while true; do
    echo "Select an option"
    echo "0. Type '0' or 'quit' to end program"
    echo "1. Convert units"
    echo "2. Add a definition"
    echo "3. Delete a definition"
    read -a user_choice
    arr_length="${#user_choice[@]}"
    option="${user_choice[0]}"
    case ${user_choice[0]}
    in
        0 | quit)
            echo "Goodbye!"
            break
            ;;
        1)
            if [[ -s definitions.txt ]]; then
                echo "Type the line number to convert units or '0' to return"
                mapfile -t lines < definitions.txt
                for i in "${!lines[@]}"; do
                    echo "$((i + 1)). ${lines[i]}"
                done
                while true; do
                    read -a user_input
                    line_number="${user_input[0]}"
                    case  "${line_number}" in
                        0)
                            break 1
                            ;;
                        [1-9]*)
                            if [[ "$line_number" -le "${#lines[@]}" ]]; then
                                echo "Enter a value to convert:"
                                while true; do
                                    read -a user_input
                                    value="${user_input[0]}"
                                    re_num='^[0-9]+([.][0-9]+)?$'
                                    if [[ "$value" =~ $re_num ]]; then
                                        definition="${lines[$((line_number - 1))]}"
                                        IFS=' ' read -r -a definition <<< "$definition"
                                        result=$(echo "scale=2; ${definition[1]} * $value" | bc -l)
                                        printf "Result: %s\n" "${result}"
                                        break 2
                                    else
                                        echo "Enter a float or integer value!"
                                    fi
                                done
                            else
                                echo "Enter a valid line number!"
                            fi
                            ;;
                        *)
                            echo "Enter a valid line number!"
                            ;;
                    esac
                done
            else
                echo "Please add a definition first!"
            fi
            ;;
        2)
            while true; do
                echo "Enter a definition:"
                read -a user_input
                arr_length="${#user_input[@]}"
                definition="${user_input[0]}"
                constant="${user_input[1]}"
                re_def='^[A-Za-z]+_to_[A-Za-z]+$'
                re_num='^[0-9]+([.][0-9]+)?$'
                if [[ "$arr_length" -eq 2 ]] && [[ "$definition" =~ $re_def ]] && [[ "$constant" =~ $re_num ]]; then
                    echo "$definition $constant" >> definitions.txt
                    break
                else
                    echo "The definition is incorrect!"
                fi
            done
            ;;
        3)
            if [[ -s definitions.txt ]]; then
                echo "Type the line number to delete or '0' to return"
                mapfile -t lines < definitions.txt
                for i in "${!lines[@]}"; do
                    echo "$((i + 1)). ${lines[i]}"
                done
                while true; do
                    read -a user_input
                    arr_length="${#user_input[@]}"
                    line_number="${user_input[0]}"
                    re_num='^[0-9]+$'
                    if [[ "$arr_length" -eq 1 ]] && [[ "$line_number" =~ $re_num ]]; then
                        if [[ "$line_number" -eq 0 ]]; then
                            break
                        elif [[ "$line_number" -le "${#lines[@]}" ]]; then
                            sed -i "${line_number}d" definitions.txt
                            break
                        else
                            echo "Enter a valid line number!"
                        fi
                    else
                        echo "Enter a valid line number!"
                    fi
                done
            else
                echo "Please add a definition first!"
            fi
            ;;
        *)
            echo "Invalid option!"
            ;;
    esac
done
