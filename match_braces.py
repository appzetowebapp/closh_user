import sys

def check_braces(filename):
    with open(filename, 'r') as f:
        text = f.read()

    stack = []
    line_num = 1
    col_num = 1
    
    in_string = False
    string_char = ''
    in_multiline_comment = False
    in_singleline_comment = False
    
    i = 0
    while i < len(text):
        char = text[i]
        
        if char == '\n':
            line_num += 1
            col_num = 1
            in_singleline_comment = False
            i += 1
            continue
            
        if not in_string and not in_multiline_comment and not in_singleline_comment:
            if char == '/' and i + 1 < len(text):
                if text[i+1] == '/':
                    in_singleline_comment = True
                    i += 2
                    col_num += 2
                    continue
                elif text[i+1] == '*':
                    in_multiline_comment = True
                    i += 2
                    col_num += 2
                    continue
            
            if char in "'\"":
                in_string = True
                string_char = char
                # Check for """ or '''
                if i + 2 < len(text) and text[i+1] == char and text[i+2] == char:
                    string_char = char * 3
                    i += 2
                    col_num += 2
            
            elif char in "{[(":
                stack.append((char, line_num, col_num))
            elif char in "}])":
                if not stack:
                    print(f"Extra '{char}' at line {line_num}, col {col_num}")
                    return
                top, t_line, t_col = stack.pop()
                expected = {'{': '}', '[': ']', '(': ')'}[top]
                if char != expected:
                    print(f"Mismatched '{char}' at line {line_num}, col {col_num}. Expected '{expected}' to match '{top}' from line {t_line}")
                    return
        
        elif in_string:
            if text[i:i+len(string_char)] == string_char:
                # Need to check if it's escaped
                escapes = 0
                j = i - 1
                while j >= 0 and text[j] == '\\':
                    escapes += 1
                    j -= 1
                if escapes % 2 == 0:
                    in_string = False
                    i += len(string_char) - 1
                    col_num += len(string_char) - 1
        
        elif in_multiline_comment:
            if char == '*' and i + 1 < len(text) and text[i+1] == '/':
                in_multiline_comment = False
                i += 1
                col_num += 1
                
        i += 1
        col_num += 1

    if stack:
        print("Unclosed braces:")
        for top, t_line, t_col in stack[-5:]:
            print(f"  '{top}' at line {t_line}, col {t_col}")
    else:
        print("All braces matched perfectly!")

check_braces('lib/screens/webview_screen.dart')
