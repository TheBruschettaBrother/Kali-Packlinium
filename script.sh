#!/bin/bash

echo ' |/  _. | o __ |_) _.  _ |  | o ._  o     ._ _
 |\ (_| | |    |  (_| (_ |< | | | | | |_| | | |  '

# Add Kali Linux repositories to sources.list
echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" | sudo tee /etc/apt/sources.list.d/kali.list
echo "deb-src http://http.kali.org/kali kali-rolling main non-free contrib" | sudo tee -a /etc/apt/sources.list.d/kali.list

# Update package lists
echo -e "\033[1;37mUpdating package lists...\033[0m"
sudo apt-get update

# Get a list of available Kali Linux metapackages
echo -e "\nGetting list of available Kali Linux metapackages..."
metapackages=($(apt-cache search kali-linux-* | grep '^kali-linux-' | cut -d ' ' -f1))

# Print the menu and get user selection
echo -e "\nWhich metapackage(s) do you want to install? (Enter comma-separated list of numbers, or 'all' to install all available metapackages)"
echo "==============================================="
if [[ $1 == "all" ]]; then
    selected_indices=$(seq 0 $((${#metapackages[@]} - 1)) | tr '\n' ',')
else
    for ((i=0; i<${#metapackages[@]}; i++)); do
        echo "$i. ${metapackages[$i]}"
    done
    read -p "Enter comma-separated list of numbers (e.g. 0,2) or 'all': " selected_indices
fi

# Split comma-separated list of indices into array
IFS=',' read -ra indices <<< "$selected_indices"

# Install selected metapackages
for index in "${indices[@]}"; do
    if [[ "${index}" == "all" ]]; then
        sudo apt-get install -y ${metapackages[@]}
        break
    else
        metapackage=${metapackages[$index]}
        echo -e "\n==============================================="
        echo -e "\nPackage: \033[1;37m${metapackage}\033[0m"
        echo "==============================================="
        dependencies=$(apt-cache depends $metapackage | grep "Depends:" | cut -d ":" -f 2- | sed 's/^[ \t]*//')
        echo -e "Depends: \033[1;33m${dependencies}\033[0m"
        read -p "Do you want to install ${metapackage}? (y/n): " install_metapackage
        if [[ "$install_metapackage" == "y" ]]; then
            sudo apt-get install -y "$metapackage"
        fi
    fi
done

echo -e "\n\033[1;32mInstallation complete!\033[0m"
