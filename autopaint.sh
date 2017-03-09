#!/bin/bash 

ITERATIONS=200


inotifywait -m /data/Photos/.input/ -e create -e moved_to |
	while read path action file; do
		echo "The file '$file' appeared in directory '$path' via '$action'"
		
		source ${path}${file}
		INPUT_FILE=$(echo ${INPUT_FILE} | sed -e "s/\//\/data\/Photos\//")
		
		STYLE_FILES=$(echo ${STYLE_FILES} | sed -e "s/,/ /g")
		STYLES=""
		STYLE_NAMES=""
		for STYLE in $STYLE_FILES; do
			STYLE_NAMES="${STYLE_NAMES} - $(echo ${STYLE} | sed -e 's/.*\///' | sed -e 's/.jpg//' | sed -e "s/[0-9]$//")"
			STYLES="${STYLES} $(echo ${STYLE} | sed -e 's/\//\/data\/Photos\//')"
		done
		STYLES=$(echo ${STYLES} | sed -e "s/^ //")
		STYLE_NAMES=$(echo ${STYLE_NAMES} | sed -e "s/^ - //" | sed -e "s/^- //")
		echo $STYLE_NAMES
		OUTPUT_FILE=$(echo ${OUTPUT_FILE} | sed -e "s/\//\/data\/Photos\//")
		
		START_TIME=$(stat -c %y ${path}${file} | sed -e "s/\.[0-9].*//")
		# Create painting
		#./neural_style.py --content /data/Photos/Pictures/$file --styles /data/Photos/Styles/$STYLE1 /data/Photos/Styles/$STYLE2 --style-blend-weights 0.5 0.5 --iterations 1300 --output /data/Photos/Paintings/$OUTPUT
		./neural_style.py --content ${INPUT_FILE} --styles ${STYLES} --iterations ${ITERATIONS} --output ${OUTPUT_FILE} --followup ${path}${file} 
		
		END_TIME=$(stat -c %y ${OUTPUT_FILE} | sed -e "s/\.[0-9].*//")
		ELAPSED=$(date -d@$(( ( $(date -ud "${END_TIME}" +'%s') - $(date -ud "${START_TIME}" +'%s') ) )) +'%M minutes %S seconds')
		echo $ELAPSED

		exiftool -Artist="${STYLE_NAMES}" /data/Photos/Paintings/$OUTPUT
		exiftool -UserComment="Generated in ${ELAPSED} by MomentTech's neural style" /data/Photos/Paintings/$OUTPUT
		chown -R www-data:www-data /data/Photos/Paintings
		rm -f $path/$file
		rm -f /tmp/$file
	done















