# Abiotic Factor kubernetes deployment dedicated server

Shoutout to DFJacob for his helpful [wiki](https://github.com/DFJacob/AbioticFactorDedicatedServer/wiki)

## deployment
  1. Add the label `requiredCPU=high` to the worker node(s) you want allow this pod to go on `kubectl label nodes kubewrk01 kubewrk02 requiredCPU=high`
  2. Clone this project down and CD into that directory
  3. Make any necessary changes (examples: change configmap, pv and pvcs..etc )
  4. Deploy the server resources:
    - this block assumes you have `envsubst` installed.
        ```
          read -p "Enter Server name(My Server): " servername
          servername=${servername:-My Server}
          read -p "Enter Player count(6): " count
          count=${count:-6}
          read -p "Enter Your STEAM ID: " steamid
          steamid=${steamid:-none}
          count=${count:-6}
          read -sp "Enter server password(none): " svr_password
          svr_password=${svr_password:-none}
          echo ""

          export SERVER_NAME=$servername
          export COUNT=$count
          export STEAMID=$steamid
          export SERVER_PASSWORD=$(echo -n $svr_password | base64)

          if [ -f "namespace.yml" ]; then
            echo "Applying namespace.yml..."
            kubectl apply -f namespace.yml
          fi
          for file in *.yml; do
            [ -e "$file" ] || continue
            echo "Applying $file..."
            if [[ "$file" == "deployment.yml" && "$svr_password" == "none" ]]; then
              sed '/-ServerPassword=_DOLLAR_JOIN_PASSWORD/d' "$file" | \
              envsubst | \
              sed 's/_DOLLAR_/\$/g' | kubectl apply -f -
            else
              envsubst < "$file" | sed 's/_DOLLAR_/\$/g' | kubectl apply -f -
            fi
          done
        ```
  5. Verify pod starts:
    - `k get pod -n abiotic-factor`
  6. Grab server's quick join code from the logs once the pod is running(Makes it easier to others to join)
    - `k logs -n abiotic-factor pods/abiotic-factor-66574f9b8c-tfj25 abiotic-factor-server`
  7. (optional) Add more server admins or setup your ban list by adding their SteamIDs to the Admin.ini block in the [configmap.yml](./configmap.yml)

Note: To patch server just restart the pod. This is a little painful if you are restarting your pod over and over since this server is not linux native and requires wine, which has a ton of dependencies.

## Troubleshooting
  - Verify the pod:
    - `k get pod -n abiotic-factor`
    - `k describe pod -n abiotic-factor`
      - review the events on the pod

  - Review pods app logs
    - Review init container logs: `k logs -n abiotic-factor pods/abiotic-factor-66574f9b8c-tfj25 init-steamcmd --follow`
      - is it having issues downloading the game files?
    - Review main container logs: `k logs -n abiotic-factor pods/abiotic-factor-66574f9b8c-tfj25 abiotic-factor-server --follow`
      - Is it having issues starting the server?

  - Verify storage is bound:
    - `k get pv -n abiotic-factor`
    - `k get pvc -n abiotic-factor`

  - Verify the service has an endpoint
    - `k describe svc -n abiotic-factor abiotic-factor-svc`

## TO DO
  - Get this working as a non root user :puke:
  - Setup network policies to lock things down even more
  - Create base 'run' image that has wine baked in.
    - This would speed up patching/deployment and is more the 'proper' way to deploy containers.
    - Note on my apt install: From my limited testing (running around the starting area), I haven't seen any issues by only installing base wine while ignoring wine64 and all recommended packages. Installing all that would make this container over 2.5G. Just wish the devs would release a native linux server binary :(
