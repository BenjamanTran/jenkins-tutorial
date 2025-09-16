#!/bin/bash

echo "Đang kiểm tra file..."
if [ -f "app/index.html" ]; then
    echo "✔️ Tồn tại file index.html"
else
    echo "❌ Không tìm thấy file index.html"
    exit 1
fi
