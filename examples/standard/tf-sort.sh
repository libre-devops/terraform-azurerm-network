#!/usr/bin/env bash

#######################################################
# tf-sort.sh Usage:
#
# This script sorts Terraform variables in alphabetical order.
#
# By default, the script will perform the sorting.
# You can use it like this:
#   ./tf-sort.sh input.tf output.tf
#
# Or with `bash`, `curl`, or `wget` and `awk`:
#   curl https://raw.githubusercontent.com/cyber-scot/utilities/main/terraform/helpers/tf-sort.sh | bash -s -- input.tf output.tf
#   wget -O - curl https://raw.githubusercontent.com/cyber-scot/utilities/main/terraform/helpers/tf-sort.sh | bash -s -- input.tf output.tf
#
# Options:
#   --append : Appends this script execution command to the user's .bashrc.
#
# Dependencies:
#   - GNUAWK
#
# Original script credits: yermulnik@gmail.com, 2021-2022
# Master copy: https://github.com/cyber-scot/utilities/blob/main/terraform/helpers/tf-sort.sh
#######################################################

# Append script execution to .bashrc
append_to_bashrc() {
    echo "Appending script execution command to .bashrc"
    echo "" >> ~/.bashrc
    echo "# Execute tf-sort.sh for Terraform sorting tasks" >> ~/.bashrc
    echo "${PWD}/tf-sort.sh" >> ~/.bashrc
}

# If --append flag is provided, add script execution to .bashrc and exit
if [[ $1 == "--append" ]]; then
    append_to_bashrc
    exit 0
fi

set -euo pipefail

tf_variables_file="${1:-variables.tf}"
sorted_tf_variables_file="${2:-outputs.tf}"

# Define and write the sorting logic to sort-tf.awk
cat <<-'EOF' >sort-tf.awk
#!/usr/bin/env -S awk -f
# https://gist.github.com/yermulnik/7e0cf991962680d406692e1db1b551e6
# Tested with GNU Awk 5.0.1, API: 2.0 (GNU MPFR 4.0.2, GNU MP 6.2.0)
# Usage: cat variables.tf | awk -f /path/to/tf_vars_sort.awk | tee sorted_variables.tf
# No licensing; yermulnik@gmail.com, 2021-2022
{
	# skip blank lines at the beginning of file
	if (!resource_type && length($0) == 0) next

	# pick only known Terraform resource definition block names of the 1st level
	# https://github.com/hashicorp/terraform/blob/main/internal/configs/parser_config.go#L55-L163
	switch ($0) {
		case /^[[:space:]]*(locals|moved|terraform)[[:space:]]+{/:
			resource_type = $1
			resource_ident = resource_type "|" block_counter++
		case /^[[:space:]]*(data|resource)[[:space:]]+("?[[:alnum:]_-]+"?[[:space:]]+){2}{/:
			resource_type = $1
			resource_subtype = $2
			resource_name = $3
			resource_ident = resource_type "|" resource_subtype "|" resource_name
		case /^[[:space:]]*(module|output|provider|variable)[[:space:]]+"?[[:alnum:]_-]+"?[[:space:]]+{/:
			resource_type = $1
			resource_name = $2
			resource_ident = resource_type "|" resource_name
	}
	arr[resource_ident] = arr[resource_ident] ? arr[resource_ident] RS $0 : $0
} END {
	# exit if there was solely empty input
	# (input consisting of multiple empty lines only, counts in as empty input too)
	if (length(arr) == 0) exit
	# declare empty array (the one to hold final result)
	split("", res)
	# case-insensitive string operations in this block
	# (primarily for the `asort()` call below)
	IGNORECASE = 1
	# sort by `resource_ident` which is a key in our case
	asort(arr)

	# blank-lines-fix each block
	for (item in arr) {
		split(arr[item],new_arr,RS)

		# remove multiple blank lines at the end of resource definition block
		while (length(new_arr[length(new_arr)]) == 0) delete new_arr[length(new_arr)]

		# add one single blank line at the end of the resource definition block
		# so that blocks are delimited with a blank like to align with TF code style
		new_arr[length(new_arr)+1] = RS

		# fill resulting array with data from each resource definition block
		for (line in new_arr) {
			# trim whitespaces at the end of each line in resource definition block
			gsub(/[[:space:]]+$/, "", new_arr[line])
			res[length(res)+1] = new_arr[line]
		}
	}

	# ensure there are no extra blank lines at the beginning and end of data
	while (length(res[1]) == 0) delete res[1]
	while (length(res[length(res)]) == 0) delete res[length(res)]

	# print resulting data to stdout
	for (line in res) {
		print res[line]
	}
}
EOF

# Execute sorting and clean up
cat "${tf_variables_file}" | awk -f sort-tf.awk | tee ${sorted_tf_variables_file} &&
  rm -rf sort-tf.awk
