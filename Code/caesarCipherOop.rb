class Caesar
  @@UPPERCASE_LETTERS = ("A".."Z").to_a
  @@LOWERCASE_LETTERS = ("a".."z").to_a

  attr_accessor :key

  def initialize(key)
    @key = key
  end

  def encrypt(text)
    encrypted = ""
    text.split("").to_a.each do |x|
      if @@UPPERCASE_LETTERS.include? x
        encrypted += @@UPPERCASE_LETTERS[ (@@UPPERCASE_LETTERS.index(x) + key) % 26]
      elsif @@LOWERCASE_LETTERS.include? x
        encrypted += @@LOWERCASE_LETTERS[ (@@LOWERCASE_LETTERS.index(x) + key) % 26]
      else
        encrypted += x
      end
    end
    return encrypted
  end


  def decrypt(text)
    decrypted = ""
    text.split("").to_a.each do |x|
      if @@UPPERCASE_LETTERS.include? x
        decrypted += @@UPPERCASE_LETTERS[ (@@UPPERCASE_LETTERS.index(x) - key) % 26]
      elsif @@LOWERCASE_LETTERS.include? x
        decrypted += @@LOWERCASE_LETTERS[ (@@LOWERCASE_LETTERS.index(x) - key) % 26]
      else
        decrypted += x
      end
    end
    return decrypted
  end
end


cipher = Caesar.new(5)

encrypt = cipher.encrypt("Hello World!")

#Encrypt
puts 'Encrypt: ' + encrypt

#Decrypt
puts 'Decrypt' + cipher.decrypt(encrypt)
