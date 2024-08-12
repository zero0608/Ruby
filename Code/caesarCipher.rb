def caesar_cipher(string, shift)
  caesar_string = ""

  string.each_char do |char|
    if ("a".."z").include?(char.downcase)
      base = char.ord < 91 ? 65 : 97  # Determine if the letter is uppercase or lowercase.
      shifted_char = (((char.ord - base) + shift) % 26) + base
      caesar_string << shifted_char.chr
    else
      caesar_string << char  # Non-letter characters remain unchanged.
    end
  end

  return caesar_string
end



print "What would you like to encrypt?"
text = gets.chomp

encrypt = caesar_cipher( text, 5 )

#Encrypt
puts 'Encrypt: ' + encrypt

#Decrypt
puts 'Decrypt' + caesar_cipher( encrypt, -5 )