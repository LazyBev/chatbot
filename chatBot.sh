#!/bin/bash

set -e

chatbot() {
    declare prompt=""
    declare -A answers

    # Load responses from file
    if [[ -f "responses.txt" ]]; then
        while IFS=":" read -r key value; do
            # Ensure the key is not empty
            if [[ -n "$key" ]]; then
                key=$(echo "$key" | tr '[:upper:]' '[:lower:]')
                answers["$key"]="$value"
            fi
        done < responses.txt
    fi

    while true; do
        read -p "> " prompt
        prompt=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')

        # Save last prompt (ignoring "!define")
        if [[ "$prompt" != "!define" ]]; then
            tempPrompt="$prompt"
        fi

        # Handle definition
        if [[ "$prompt" == "!define" ]]; then
            new_key=$(echo "$tempPrompt" | tr '[:upper:]' '[:lower:]')
            
            # Prevent redefining "!define"
            if [[ "$new_key" == "!define" ]]; then
                echo "You cannot define '!define' as a key."
                continue
            fi
            
            read -p "Provide a response: " new_response
            
            if [[ -z "$new_response" ]]; then
                echo "Response cannot be empty. Please try again."
                continue
            fi
            
            # Save response and append to file
            answers["$new_key"]="$new_response"
            echo -e "$new_key:$new_response" >> responses.txt
            echo "Definition saved."
            continue
        fi

        found_matches=()
        match_found=false

        # Search for key matches
        for key in "${!answers[@]}"; do
            if [[ "$prompt" == *"$key"* ]]; then
                found_matches+=("$key:${answers[$key]}")
                match_found=true
            fi
        done

        # If no matches were found
        if ! $match_found; then
            echo "I didn't quite catch that. Could you repeat your prompt?"
        else
            # Find the closest match (longest match)
            closest_match="${found_matches[0]}"
            for match in "${found_matches[@]}"; do
                if [[ "${#match}" -gt "${#closest_match}" ]]; then
                    closest_match="$match"
                fi
            done

            # Display the response
            echo "${closest_match##*:}"
        fi
    done  
}

echo "Welcome to BevGPT, a chatbot that assists you (enter '!define' to generate an answer for a prompt)"
chatbot
