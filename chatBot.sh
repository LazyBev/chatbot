#!/bin/bash

set -e

chatbot() {
    declare prompt=""
    declare -A answers

    if [[ -f "responses.txt" ]]; then
        while IFS=":" read -r key value; do
            key=$(echo "$key" | tr '[:upper:]' '[:lower:]')
            answers["$key"]="$value"
        done < responses.txt
    fi

    while true; do
        read -p "> " prompt
        prompt=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')

        if [[ "$prompt" == "!define" ]]; then
            read -p "Define a prompt: " new_key
            new_key=$(echo "$new_key" | tr '[:upper:]' '[:lower:]')
            read -p "Provide a response: " new_response
            
            if [[ -z "$new_response" ]]; then
                echo "Response cannot be empty. Please try again."
                continue
            fi
            
            answers["$new_key"]="$new_response"
            echo -e "$new_key:$new_response" >> responses.txt
            echo "Definition saved."
            continue
        fi

        found_matches=()
        match_found=false

        for key in "${!answers[@]}"; do
            if [[ "$prompt" == *"$key"* ]]; then
                found_matches+=("$key:${answers[$key]}")
                match_found=true
            fi
        done

        if ! $match_found; then
            echo "I didn't quite catch that. Could you repeat your prompt?"
        else
            closest_match="${found_matches[0]}"
            for match in "${found_matches[@]}"; do
                if [[ "${#match}" -gt "${#closest_match}" ]]; then
                    closest_match="$match"
                fi
            done

            echo "${closest_match##*:}"
        fi
    done  
}

chatbot
