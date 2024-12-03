package main

import (
	"crypto/md5"
	"crypto/sha1"
	"crypto/sha256"
	"crypto/sha512"
	"encoding/hex"
	"fmt"
	"hash"
	"hash/adler32"
	"hash/crc32"
	"io"
	"os"
	"strings"
)

type hashFunc struct {
	name string
	hash hash.Hash
}

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <file_path>\n", os.Args[0])
		os.Exit(1)
	}

	filePath := os.Args[1]
	file, err := os.Open(filePath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error opening file: %v\n", err)
		os.Exit(1)
	}
	defer file.Close()

	// Initialize all hash functions
	hashFuncs := []hashFunc{
		{"MD5", md5.New()},
		{"SHA1", sha1.New()},
		{"SHA256", sha256.New()},
		{"SHA512", sha512.New()},
		{"CRC32", crc32.NewIEEE()},
		{"Adler32", adler32.New()},
	}

	// Create a multiwriter to write to all hashes at once
	writers := make([]io.Writer, len(hashFuncs))
	for i, h := range hashFuncs {
		writers[i] = h.hash
	}
	multiWriter := io.MultiWriter(writers...)

	// Copy file content to all hashes at once
	if _, err := io.Copy(multiWriter, file); err != nil {
		fmt.Fprintf(os.Stderr, "Error reading file: %v\n", err)
		os.Exit(1)
	}

	// Print file name
	fmt.Printf("File: %s\n", filePath)
	fmt.Println(strings.Repeat("-", 50))

	// Calculate and print all hashes
	for _, h := range hashFuncs {
		hashSum := h.hash.Sum(nil)
		fmt.Printf("%s: %s\n", h.name, hex.EncodeToString(hashSum))
	}
}
