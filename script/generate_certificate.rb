#!/usr/bin/ruby

require "openssl"

PRIV = OpenSSL::PKey::EC.new(
  "\x30\x77\x02\x01\x01\x04\x20\x03\x84\x2a\xc7\xf4\xcd\xe3\x67\xde"\
  "\xa0\x56\xc6\x4f\x7f\x3b\x15\xea\x7d\x4b\xc4\x83\xca\xc6\x97\x9f"\
  "\x2a\x31\x93\xad\x57\x31\x09\xa0\x0a\x06\x08\x2a\x86\x48\xce\x3d"\
  "\x03\x01\x07\xa1\x44\x03\x42\x00\x04\xf6\x9c\xab\x24\x14\x4b\xb4"\
  "\xef\x87\xf7\x0f\x23\x1c\x5c\xd4\xf5\x78\x04\xac\xf8\xe0\xc6\xb2"\
  "\xb3\xe3\x52\x18\x3d\x80\x39\x1f\x6b\xd2\x79\xd2\x6a\x4c\x83\x64"\
  "\x74\xe6\xc2\xda\x23\x93\xff\xac\x1d\x50\x34\x6c\x5c\x23\x90\x65"\
  "\x57\x93\x3e\xcb\x93\xff\x6e\xde\xd1"
)

# From "FIDO U2F Authenticator Transports Extension" spec.
# X509 Extension OID for specifying supported transports.
U2F_TRANSPORT_EXTENSION_OID = "1.3.6.1.4.1.45724.2.1.1"

# From "FIDO U2F Authenticator Transports Extension" spec.
# BIT STRING values for U2F_TRANSPORT_EXTENSION_OID.
U2F_TRANSPORT_BLUETOOTH_RADIO            = 0b10000000
U2F_TRANSPORT_BLUETOOTH_LOW_ENERGY_RADIO = 0b01000000
U2F_TRANSPORT_USB                        = 0b00100000
U2F_TRANSPORT_NFC                        = 0b00010000
U2F_TRANSPORT_USB_INTERNAL               = 0b00001000

SECOND = 1
MINUTE = 60  * SECOND
HOUR   = 60  * MINUTE
DAY    = 24  * HOUR
YEAR   = 365 * DAY

def bit_string_extension(oid, value)
  bsvalue = OpenSSL::ASN1::BitString.new([value].pack("C*"))

  # There's probably a "smart" way to do this.
  bsvalue.unused_bits = value.to_s(2).match(/(0*)$/)[1].size

  OpenSSL::X509::Extension.new(oid, bsvalue, false)
end

def generate_cert(private_key:, subject:, transports:)
  # https://bugs.ruby-lang.org/issues/8177
  private_key.define_singleton_method(:private?) { private_key? }
  private_key.define_singleton_method(:public?) { public_key? }

  OpenSSL::X509::Certificate.new().tap do |cert|
    cert.serial = 1
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + (10 * YEAR)
    cert.public_key = private_key

    cert.add_extension(bit_string_extension(
      U2F_TRANSPORT_EXTENSION_OID,
      transports
    ))

    cert.sign(private_key, OpenSSL::Digest::SHA256.new)
  end
end

cert = generate_cert(
  private_key: PRIV,
  subject: "CN=Soft U2F/O=GitHub Inc./OU=Security",
  transports: U2F_TRANSPORT_USB_INTERNAL,
).to_der

puts "Cert size: #{cert.bytesize}"

puts "Cert: "
cert.bytes.each_slice(16) do |bytes|
  line = bytes.map { |b| "\\x%02x" % b }.join
  puts %Q["#{line}"]
end
