#/bin/sh

CONTENT=$1
STYLE_NAME=$(echo "$2" | sed -e "s/\.jpg//")
NAME=$(echo "$1" | sed -e "s/\.jpg//" | sed -e "s/.*\///")
OUTPUT_NAME=$NAME-$STYLE_NAME

ITERATIONS=1000
LAST_OUT=$OUTPUT_NAME-final
STEP=0

function paint {
	if [ "$STEP" == 0 ]; then
		echo 1
		time python neural_style.py --content $CONTENT --styles styles/$STYLE_NAME.jpg --output /data/$LAST_OUT.jpg --checkpoint-output /data/$OUTPUT_NAME-%s.jpg --iterations $ITERATIONS
	else	
		time python neural_style.py --content $CONTENT --styles styles/$STYLE_NAME.jpg --output /data/$LAST_OUT.jpg --checkpoint-output /data/$OUTPUT_NAME-%s.jpg --checkpoint-iterations $STEP --iterations $ITERATIONS
	fi
}

if [ "$2" == "all" ]; then
	STYLES=$(ls styles/* | sed -e "s/.*\///" | sed -e "s/\.jpg//")
	for STYLE_NAME in $STYLES; do
		OUTPUT_NAME=$NAME-$STYLE_NAME
		LAST_OUT=$OUTPUT_NAME-final
		echo "##############################################"
		echo "Painting $NAME with sytle $STYLE_NAME ..."
		paint
		echo "Done"
		echo "##############################################"
	done
else
	paint
fi


