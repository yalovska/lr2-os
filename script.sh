#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Використання: $0 <csv_file>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Файл $FILE не знайдено"
    exit 1
fi

awk -F',' '
{
    for (i = 1; i <= NF; i++) {
        if ($i == "\"tax\"" || $i == "tax") {
            tax_col = i
            break
        }
    }
    
    if (NR == 1) {
        print $0
        next
    }
    
    if (tax_col == 0) {
        print $0
        next
    }
    
    value = $tax_col
    gsub(/"/, "", value)
    
    if (value ~ /^[0-9]*\.?[0-9]{1,2}$/ && value >= 0 && value <= 1) {
        # Конвертуємо у відсотки
        percent = value * 100
        $tax_col = percent "%"
    } else if (value == "") {
        $tax_col = "N/A"
    } else if (value ~ /^[0-9]/) {
        $tax_col = "N/A"
    } else {
        $tax_col = "N/A"
    }
    
    print $0
}' "$FILE"
