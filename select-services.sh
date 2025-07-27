#!/bin/bash

# Configuració
INPUT_FILE="modules.list"
SELECTED_FILE="modules_selected.list"
CONFIG_FILE="modules_config.conf"
TEMP_FILE="/tmp/whiptail_selection"

# Funcions auxiliars
show_usage() {
    echo "Ús: $0 [opcions]"
    echo "Opcions:"
    echo "  -h, --help     Mostra aquesta ajuda"
    echo "  -r, --reset    Reinicia la selecció"
    echo "  -s, --show     Mostra els mòduls actualment seleccionats"
}

# Carregar mòduls prèviament seleccionats
load_previous_selection() {
    if [[ -f "$SELECTED_FILE" ]]; then
        declare -A selected_modules
        while IFS= read -r line; do
            [[ -n "$line" ]] && selected_modules["$line"]=1
        done < "$SELECTED_FILE"
        echo "$(declare -p selected_modules)"
    fi
}

# Processar arguments
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -r|--reset)
        rm -f "$SELECTED_FILE" "$CONFIG_FILE"
        echo "Selecció reiniciada"
        exit 0
        ;;
    -s|--show)
        if [[ -f "$SELECTED_FILE" ]]; then
            echo "Mòduls actualment seleccionats:"
            cat "$SELECTED_FILE"
        else
            echo "No hi ha mòduls seleccionats"
        fi
        exit 0
        ;;
esac

# Comprovar fitxer d'entrada
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: No es troba el fitxer $INPUT_FILE"
    exit 1
fi

# Carregar selecció anterior si existeix
eval "$(load_previous_selection)"

# Preparar opcions per whiptail
OPTIONS=()
COUNTER=1
declare -A module_map

while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    # Determinar si està seleccionat
    if [[ -n "${selected_modules["$line"]:-}" ]]; then
        state="ON"
    else
        state="OFF"
    fi
    
    # Crear descripció més llegible
    module_name=$(echo "$line" | cut -d' ' -f1)
    module_desc=$(echo "$line" | cut -d' ' -f2- | sed 's/^[[:space:]]*//')
    [[ -z "$module_desc" ]] && module_desc="$module_name"
    
    OPTIONS+=("$COUNTER" "$module_name - $module_desc" "$state")
    module_map["$COUNTER"]="$line"
    ((COUNTER++))
done < "$INPUT_FILE"

if [[ ${#OPTIONS[@]} -eq 0 ]]; then
    echo "Error: No s'han trobat mòduls vàlids"
    exit 1
fi

# Calcular dimensions dinàmiques
TOTAL_MODULES=$((COUNTER - 1))
LIST_HEIGHT=$((TOTAL_MODULES > 15 ? 15 : TOTAL_MODULES))
DIALOG_HEIGHT=$((LIST_HEIGHT + 8))

# Mostrar diàleg
whiptail --title "🔧 Selector de Mòduls del Sistema" \
         --checklist "Utilitza ESPAI per seleccionar/deseleccionar, TAB per navegar i ENTER per confirmar:" \
         $DIALOG_HEIGHT 90 $LIST_HEIGHT \
         "${OPTIONS[@]}" \
         2> "$TEMP_FILE"

if [[ $? -ne 0 ]]; then
    echo "Operació cancel·lada"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Processar seleccions
SELECTED=$(cat "$TEMP_FILE")
rm -f "$TEMP_FILE"

# Crear fitxer amb mòduls seleccionats
> "$SELECTED_FILE"
SELECTED_COUNT=0

if [[ -n "$SELECTED" ]]; then
    for num in $(echo "$SELECTED" | tr -d '"'); do
        if [[ -n "${module_map[$num]:-}" ]]; then
            echo "${module_map[$num]}" >> "$SELECTED_FILE"
            ((SELECTED_COUNT++))
        fi
    done
fi

# Mostrar resum
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  RESUM DE LA SELECCIÓ"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Mòduls disponibles: $TOTAL_MODULES"
echo "Mòduls seleccionats: $SELECTED_COUNT"
echo "Fitxer de sortida: $SELECTED_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $SELECTED_COUNT -gt 0 ]]; then
    echo -e "\n📦 Mòduls seleccionats:"
    nl -w2 -s'. ' "$SELECTED_FILE"
else
    echo -e "\n⚠️  No s'ha seleccionat cap mòdul"
fi
