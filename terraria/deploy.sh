read -p "Enter Server name(My Server): " servername
servername=${servername:-My Server}
echo ""

read -p "Enter Server Port. Default 7777: " port
port=${port:-7777}
echo ""

printf "Enter max player count\nValue must be between 1 and 255. Default 8"
read -p ": " playercount
playercount=${playercount:-8}
echo ""

printf "Enter Wolrd difficulty\n0(classic), 1(expert), 2(master), 3(journey). Default 0"
read -p ": " difficulty
difficulty=${difficulty:-0}
echo ""

printf "Enter Wolrd size\n1(small), 2(medium), and 3(large). Default 3"
read -p ": " size
size=${size:-3}
echo ""

printf "Enter Custom message of the day\nDefault: 'Welcome to ${servername}'"
read -p ": " motd
motd=${motd:-"Welcome to $servername"}
echo ""

read -sp "Enter server password(none): " svr_password
svr_password=${svr_password:-none}
echo ""

export SERVER_NAME=$servername
export PORT=$port
export COUNT=$playercount
export DIFFICULTY=$difficulty
export WORLD_SIZE=$size
export MOTD=$motd
export SERVER_PASSWORD=$(echo -n $svr_password | base64)

if [ -f "namespace.yml" ]; then
    echo "Applying namespace.yml..."
    kubectl apply -f namespace.yml
fi
for file in *.yml; do
    [ -e "$file" ] || continue
    if [[ "$file" == "deployment.yml" && "$svr_password" == "none" ]]; then
        echo "Applying $file..."
        sed '/-password _DOLLAR_JOIN_PASSWORD/d' "$file" | \
        envsubst | \
        sed 's/_DOLLAR_/\$/g' | kubectl apply -f -
    else
        echo "Applying $file..."
        envsubst < "$file" | sed 's/_DOLLAR_/\$/g' | kubectl apply -f -
    fi
done