path = vim.vars['vim_hex_dir'].decode("UTF-8")
sys.path.append(path)
from vim_hex import hd_vim_buffer, binarize_vim_buffer
import vim

if __name__ == "__main__":
    pos = vim.current.window.cursor
    binarize_vim_buffer()
    vim.command("w")
    vim.command("call BufferToGlobal()")
    hd_vim_buffer()

