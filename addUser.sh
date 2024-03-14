#!/bin/bash

# ایجاد نام کاربری
read -p "لطفاً نام کاربری جدید را وارد کنید: " username
sudo adduser $username

# تنظیم اجازه SSH
sudo usermod -aG ssh $username

# تنظیم رمز عبور
sudo passwd $username

# نمایش نام کاربری و رمز عبور
echo "نام کاربری: $username"
read -s -p "لطفاً رمز عبور را وارد کنید: " password
echo "رمز عبور: $password"
