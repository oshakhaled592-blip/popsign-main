import os

files = [
    'lib/features/initialization/ui/screens/reset_screen.dart',
    'lib/features/initialization/ui/screens/word_list_screen.dart',
    'lib/features/initialization/ui/screens/lost_page_screen.dart',
    'lib/features/initialization/ui/screens/learn_new_words_screen.dart',
    'lib/features/initialization/ui/screens/profile._screen.dart',
    'lib/features/auth/login/ui/screen/login_screen.dart',
    'lib/core/routing/app_router.dart',
    'lib/core/routing/routes.dart',
    'lib/features/initialization/ui/screens/pre_start_screen.dart',
    'lib/features/initialization/ui/screens/select_categories_screen.dart',
    'lib/features/auth/signup/ui/screen/signup_screen.dart',
    'lib/features/initialization/ui/screens/choose_language_screen.dart',
    'lib/features/auth/login/ui/screen/forgot_password_screen.dart',
    'lib/main.dart',
    'lib/core/theme/theme_notifier.dart',
]

def strip_inline_comment(line):
    in_str = False
    str_char = None
    i = 0
    while i < len(line):
        c = line[i]
        if not in_str and c in ('"', "'"):
            in_str = True
            str_char = c
        elif in_str and c == str_char and (i == 0 or line[i-1] != '\\'):
            in_str = False
            str_char = None
        elif not in_str and c == '/' and i + 1 < len(line) and line[i+1] == '/':
            trimmed = line[:i].rstrip()
            return (trimmed + '\n') if trimmed else ''
        i += 1
    return line

def remove_comments(lines):
    result = []
    prev_blank = False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith('//'):
            continue
        if '//' in line:
            line = strip_inline_comment(line)
        if not line.strip():
            if not prev_blank and result:
                result.append('\n')
            prev_blank = True
        else:
            result.append(line if line.endswith('\n') else line + '\n')
            prev_blank = False
    return result

for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    cleaned = remove_comments(lines)
    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(cleaned)
    print('done:', path)
