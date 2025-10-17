BASE_URL_DEV="https://dev.test.com"
BASE_URL_STAGE="https://stage.test.com"
BASE_URL_PROD="https://test.com"

# TODO: add flavor params her

for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

args=()

args+=($ACTION)
args+=($PLATFORM)
args+=(--$TYPE)

if [[ "$PLATFORM" == "ios" ]]
then
case $LAUNCH_FILE in
	"lib/main_dev.dart") \
		sed -i '' 's/Flavor.prodTest/Flavor.dev/g' lib/main.dart && \
        sed -i '' 's/Flavor.stage/Flavor.dev/g' lib/main.dart && \
        sed -i '' 's/Flavor.prod/Flavor.dev/g' lib/main.dart ;;
	"lib/main_stage.dart") \
		sed -i '' 's/Flavor.prodTest/Flavor.stage/g' lib/main.dart && \
        sed -i '' 's/Flavor.dev/Flavor.stage/g' lib/main.dart && \
        sed -i '' 's/Flavor.prod/Flavor.stage/g' lib/main.dart ;;
	"lib/main_prod.dart") \
		sed -i '' 's/Flavor.dev/Flavor.prod/g' lib/main.dart && \
        sed -i '' 's/Flavor.stage/Flavor.prod/g' lib/main.dart && \
        sed -i '' 's/Flavor.prod/Flavor.prod/g' lib/main.dart ;;
	*)
        sed -i '' 's/Flavor.dev/Flavor.prod/g' lib/main.dart && \
        sed -i '' 's/Flavor.stage/Flavor.prod/g' lib/main.dart && \
        sed -i '' 's/Flavor.prodTest/Flavor.prod/g' lib/main.dart ;;
esac
fi

args+=(-t $LAUNCH_FILE)

if [[ "$PLATFORM" == "apk" || "$PLATFORM" == "appbundle" ]]
then
args+=(--flavor $FLAVOR)
fi

if [[ "$PLATFORM" == "ios" && "$CODE_SIGN" == "NO" ]]
then
args+=(--no-codesign)
fi

if [[ "$OBFUSCATE" == "YES" ]]
then
args+=(--obfuscate)
args+=(--split-debug-info=./debug_symbols)
fi

args+=(--dart-define="BASE_URL_DEV=$BASE_URL_DEV")
args+=(--dart-define="BASE_URL_STAGE=$BASE_URL_STAGE")
args+=(--dart-define="BASE_URL_PROD=$BASE_URL_PROD")

# TODO: add flavor params here

flutter "${args[@]}"
