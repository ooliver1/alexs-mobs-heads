output=`curl \
-H "Authorization: Bearer $1" \
-F variant=classic \
-F file="@textures/$2;type=image/png" \
https://api.minecraftservices.com/minecraft/profile/skins -v`

# Get 4 x 32 bit ints from the UUID
uuid=`echo $output | jq '.skins[0].id'`
int1=$((0x${uuid:1:8}))
int2=$((0x${uuid:10:4}${uuid:15:4}))
int3=$((0x${uuid:20:4}${uuid:25:4}))
int4=$((0x${uuid:29:8}))

# Convert to 2's complement
for var in int1 int2 int3 int4; do
    if (( $var > 2147483647 )); then
        (( $var -= 4294967296 ))
    fi
done

# Use int-array UUID format (for NBT)
uuid=`printf "[I;%d,%d,%d,%d]\n" "$int1" "$int2" "$int3" "$int4"`

url=`echo $output | jq '.skins[0].url'`
head="{\"textures\":{\"SKIN\":{\"url\":$url}}}"
b64=`echo -n $head | base64 -w 0`

echo $uuid
echo $b64
