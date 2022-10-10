path = vim.vars['vim_hex_dir'].decode("UTF-8")
sys.path.append(path)
from vim_hex import hd_vim_buffer, binarize_vim_buffer

if __name__ == "__main__":
    print("lolilol")
    hd_vim_buffer()

