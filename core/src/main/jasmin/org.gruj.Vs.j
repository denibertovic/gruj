.class public org/gruj/Vs
.super java/lang/Object

.method private static cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
  ;{
    .limit locals 2
    .limit stack 3

    aload_0
    ldc "[N/A]"

    aload_1
    ifnull CT_null
    ;{
      pop
      aload_1
      invokestatic java/lang/String.valueOf(Ljava/lang/Object;)Ljava/lang/String;
    ;}
CT_null:

    invokevirtual java/lang/String.concat(Ljava/lang/String;)Ljava/lang/String;
    areturn
  ;}
.end method

.method private static info(Ljava/lang/String;Z)V
  ;{
    .limit locals 2
    .limit stack 4

    iload_1
    ifne OUT_quiet
    ;{
      getstatic java/lang/System/out Ljava/io/PrintStream;
      ldc "[info] "
      aload_0
      invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
      invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
    ;}
OUT_quiet:

    return
  ;}
.end method

.method public static main([Ljava/lang/String;)V
  ;{
    .limit locals 12
    .limit stack 8

    .catch all from UC_not_null to UC_loaded using UC_error
    .catch all from FC_not_null to FC_loaded using FC_error
    .catch all from FE_read to FE_error using FE_error
    .catch all from FD_read to FD_error using FD_error
    .catch all from FO_write to FO_error using FO_error
    .catch all from MC_seek to MC_test using MC_crash
    .catch all from MC_load to MC_crash using MC_crash

; +======================++
;  \  Meet the variables ||
;   ^====================++

;  0 : [args]      - init args [replaced with pass-through params after parsing]
;  1 : [foo]       - temporary variable 1
;  2 : [bar]       - temporary variable 2
;  3 : [quiet]     - quiet [false by default, used in call to info method]
;  4 : [argLen]    - length of init args array
;  5 : [delete]    - delete [false by default]
;  6 : [checksum]  - checksum [String, optional (can be null)]
;  7 : [mainClass] - mainClass [String, optional (can be "")]
;  8 : [URL]       - URL [String, replaced with java.net.URL after parsing]
;  9 : [file]      - file [String, replaced with java.io.File after parsing]
; 10 : [checkType] - checksum type [String, optional (can by null)]
; 11 : [body]      - buffer for reading, checking digest and writing

; +=========================================================++
;  \  Initialize the local variables, args are already in 0 ||
;   ^=======================================================++

    iconst_0
    istore_3 ; [quiet]

    iconst_0
    istore 5 ; [delete]

    aconst_null
    astore 6 ; [checksum]

    aconst_null
    astore 7 ; [mainClass]

    aconst_null
    astore 8 ; [URL]

    aconst_null
    astore 9 ; [file]

    aconst_null
    astore 10 ; [checkType]

    aconst_null
    astore 11 ; [body]

; +==============================================++
;  \   Check if gruj was run with < 2 arguments, ||
;   \  if that is so output usage and exit       ||
;    ^===========================================++

    aload_0 ; [args]
    arraylength

    dup
    istore 4 ; [argLen]

    iconst_2
    if_icmpge EP_skip_usage
    ;{
      ldc "Usage:"
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V
      ldc "  java -jar gruj.jar [options] url/src.jar [path/]target.jar [arguments]"
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V
      ldc "Options:"
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V
      ldc "  -q        ~ Quiet mode - do not output info messages to stdout"
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V
      ldc "  -c[hash]  ~ Check the file againts SHA-1 or MD5 checksum"
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V
      ldc "  -d        ~ Delete the cached file on checksum mismatch"
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V
      ldc "  -m[class] ~ Override main class or pass empty to skip run"

OK_exit:
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V
      iconst_0

DO_exit:
      invokestatic java/lang/System.exit(I)V
      return
    ;}

; +=============================================++
;  \   Ouputs an error, and exists with code -1 ||
;   ^===========================================++

error:
;{
    getstatic java/lang/System/out Ljava/io/PrintStream;
    swap
    ldc "[error] "
    swap
    invokevirtual java/lang/String.concat(Ljava/lang/String;)Ljava/lang/String;
    invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V

    iconst_m1
    goto DO_exit
;}

EP_skip_usage:

; +===============================================++
;  \   Run a parse loop, checking for options     ||
;   \  starting with -, and set URL and file vars ||
;    ^============================================++

    iconst_0
    istore_2 ; [bar]

PL_continue:
    iload_2 ; [bar]
    iload 4 ; [argLen]

    if_icmpge PL_end
    ;{
      aload_0 ; [args]
      iload_2 ; [bar]
      aaload

      iinc 2 1 ; [bar]

      dup
      invokevirtual java/lang/String.length()I

      iconst_2
      isub
      dup
      istore_1 ; [foo]

      iflt PL_not_option

      dup
      iconst_0
      invokevirtual java/lang/String.charAt(I)C
      bipush 16
      ishl

      swap
      dup_x1
      iconst_1
      invokevirtual java/lang/String.charAt(I)C
      iadd

      lookupswitch
        0x2d0063: PL_set_checksum  ; -c
        0x2d0064: PL_set_delete    ; -d
        0x2d006d: PL_set_mainClass ; -m
        0x2d0071: PL_set_quiet     ; -q
      default: PL_not_option

PL_set_quiet:
      iload_1 ; [foo]
      ifgt PL_not_option
      pop
      iconst_1
      istore_3 ; [quiet]
      goto PL_continue

PL_set_delete:
      iload_1 ; [foo]
      ifgt PL_not_option
      pop
      iconst_1
      istore 5 ; [delete]
      goto PL_continue

PL_set_checksum:
      iconst_2
      invokevirtual java/lang/String.substring(I)Ljava/lang/String;
      astore 6 ; [checksum]
      goto PL_continue

PL_set_mainClass:
      iconst_2
      invokevirtual java/lang/String.substring(I)Ljava/lang/String;
      astore 7 ; [mainClass]
      goto PL_continue

PL_not_option:
      aload 8 ; [URL]
      ifnonnull PL_not_URL
      ;{
        astore 8 ; [URL]
        goto PL_continue
      ;}

PL_not_URL:
      astore 9 ; [file]
    ;}
PL_end:

; +================================================++
;  \   Copy the remaining arguments to a new array ||
;   ^==============================================++

    iload 4 ; [argLen]
    iload_2 ; [bar]
    isub
    dup

    anewarray java/lang/String
    iconst_m1

SA_continue:

    iload_2 ; [bar]
    iload 4 ; [argLen]

    if_icmpge SA_end
    ;{
      iconst_1
      iadd
      dup2

      aload_0 ; [args]
      iload_2 ; [bar]
      iinc 2 1 ; [bar]
      aaload

      aastore
      goto SA_continue
    ;}
SA_end:

; +===========================================++
;  \   After this point, var [args] hold only ||
;   \  the pass-through arguments (replaced)  ||
;    ^========================================++

    pop
    astore_0 ; [args]
    istore 4 ; [argLen]

; +====================================++
;  \   Parsing finished, start program ||
;   ^==================================++

    ldc "Starting gruj v0.1.3 with parameters:"
    iload_3 ; [quiet]
    invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V

; +=============================++
;  \   Echo checksum if defined ||
;   ^===========================++

    aload 6 ; [checksum]
    ifnull SP_skip_checksum
    ;{
      ldc "  Checksum: "
      aload 6 ; [checksum]
      invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
      iload 5 ; [delete]

      ifeq SP_skip_delete
      ;{
        ldc " [delete on mismatch]"
        invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
      ;}
SP_skip_delete:

      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V
    ;}
SP_skip_checksum:

; +=============++
;  \   Echo URL ||
;   ^===========++

    ldc "  URL: "
    aload 8 ; [URL]
    invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
    iload_3 ; [quiet]
    invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V

; +==============++
;  \   Echo File ||
;   ^============++

    ldc "  File: "
    aload 9 ; [file]
    invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
    iload_3 ; [quiet]
    invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V

; +====================++
;  \   Echo Main class ||
;   ^==================++

    aload 7 ; [mainClass]
    ifnull SP_skip_mainClass
    ;{
      ldc "  Main class: "
      aload 7 ; [mainClass]
      dup
      invokevirtual java/lang/String.length()I

      ifne SP_mainClass_set
      ;{
        pop
        ldc "[N/A]"
      ;}
SP_mainClass_set:

      invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V
    ;}
SP_skip_mainClass:

; +=================================++
;  \   Echo Pass-through parameters ||
;   ^===============================++

    iload 4 ; [argLen]
    ifeq SP_skip

    ldc "  Pass-through parameters:"
    iconst_0
    istore_1 ; [foo]

SP_continue:
    iload_1 ; [foo]
    iload 4 ; [argLen]

    if_icmpge SP_end
    ;{
      ldc " \""
      invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;

      aload_0 ; [args]
      iload_1 ; [foo]
      aaload
      ;{
        ldc "[\\\\\\\"]"
        ldc "\\\\$0"
        invokevirtual java/lang/String.replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
      ;}
      invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;

      ldc "\""
      invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
    ;}
    iinc 1 1 ; [foo]
    goto SP_continue

SP_end:
    iload_3 ; [quiet]
    invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V

SP_skip:

; +================================++
;  \   Determine the checksum type ||
;   ^==============================++

    aload 6 ; [checksum]
    ifnull CT_skip
    ;{
      aload 6 ; [checksum]
      ldc "[0-9a-fA-F]*"
      invokevirtual java/lang/String.matches(Ljava/lang/String;)Z

      ifne CT_chars_OK
      ;{
        ldc "Checksum can only contain hexadecimal characters!"
        goto error
      ;}
CT_chars_OK:

      aload 6 ; [checksum]
      invokevirtual java/lang/String.length()I

      dup
      bipush 32
      if_icmpne CT_not_MD5
      ;{
        ldc "MD5"
        goto CT_set_method
      ;}
CT_not_MD5:

      dup
      bipush 40
      if_icmpne CT_not_SHA1
      ;{
        ldc "SHA-1"
        goto CT_set_method
      ;}
CT_not_SHA1:

      ldc "No checksum specified! (checksum must immediately follow the -c flag)"
      swap
      ifeq CT_report_empty
      ;{
        pop
        ldc "Invalid checksum length - it must either be 32 (MD5) or 40 (SHA-1) characters in length!"
      ;}
CT_report_empty:

      goto error

CT_set_method:

      astore 10 ; [checkType]
      pop
    ;}

CT_skip:

; +==============================++
;  \   URL string initialization ||
;   ^============================++

    aload 8 ; [URL]
    ifnonnull UC_not_null
    ;{
      ldc "URL was not defined!"
      goto error
    ;}

UC_error:
    ldc "URL could not be initialized"

TH_error:
    ldc " ("
    invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
    swap
    invokevirtual java/lang/Throwable.getMessage()Ljava/lang/String;
    invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
    ldc ")!"
    invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;

    goto error

UC_not_null:

    new java/net/URL
    dup
    aload 8 ; [URL]
    invokenonvirtual java/net/URL.<init>(Ljava/lang/String;)V
    astore 8 ; [URL]

; +===========================================++
;  \   From this point on, local variable URL ||
;   \  is no longer a String, but a URL       ||
;    ^========================================++

UC_loaded:

; +===============================++
;  \   File string initialization ||
;   ^=============================++

    aload 9 ; [file]
    ifnonnull FC_not_null
    ;{
      ldc "File was not defined!"
      goto error
    ;}

FC_error:
    ldc "File could not be initialized"
    goto TH_error

FC_not_null:
    new java/io/File
    dup
    aload 9 ; [file]
    invokenonvirtual java/io/File.<init>(Ljava/lang/String;)V

    invokevirtual java/io/File.getCanonicalFile()Ljava/io/File;
    dup
    astore 9 ; [file]

; +================================================++
;  \   From this point on, local variable file     ||
;   \  is no longer a String, but a canonical File ||
;    ^=============================================++

    invokevirtual java/io/File.getParentFile()Ljava/io/File;
    dup
    invokevirtual java/io/File.isDirectory()Z
    ifne FC_parent_exists
    ;{
      invokevirtual java/io/File.mkdirs()Z
      ifne FC_parent_OK
      ;{
        ldc "Could not create parent folder!"
        goto error
      ;}
FC_parent_OK:

      ldc "Created parent folder ..."
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V

      aconst_null
    ;}
FC_parent_exists:
    pop

FC_loaded:

; +============================================++
;  \   If file exists, read it and calc digest ||
;   ^==========================================++

    aload 9 ; [file]
    invokevirtual java/io/File.exists()Z
    ifeq FE_no_file
    ;{
      aconst_null
      astore_1 ; [foo]

FE_read:
      new java/io/FileInputStream
      dup

      aload 9 ; [file]
      dup

      invokevirtual java/io/File.length()J
      l2i
      newarray byte
      astore 11 ; [body]

      invokenonvirtual java/io/FileInputStream.<init>(Ljava/io/File;)V
      astore_1 ; [foo]

      aload_1 ; [foo]
      aload 11 ; [body]
      invokevirtual java/io/FileInputStream.read([B)I
      pop

      aload_1 ; [foo]
      invokevirtual java/io/FileInputStream.close()V
      goto FE_fin

FE_error:
      aload_1 ; [foo]
      ifnull FE_skip_close
      ;{
        aload_1 ; [foo]
        invokevirtual java/io/FileInputStream.close()V
      ;}
FE_skip_close:
      ldc "File could not be read"
      goto TH_error

FE_fin:

; +=============================================++
;  \   Check digest only if checksum is defined ||
;   ^===========================================++

      aload 10 ; [checkType]
      ifnull FE_skip_check
      ;{
        iconst_0
        ldc "Cached file exists, calculated checksum: "

CH_calc:
        aload 10 ; [checkType]
        invokestatic java/security/MessageDigest.getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

        aload 11 ; [body]
        invokevirtual java/security/MessageDigest.digest([B)[B
        invokestatic javax/xml/bind/DatatypeConverter.printHexBinary([B)Ljava/lang/String;

        dup
        aload 6 ; [checksum]
        invokevirtual java/lang/String.equalsIgnoreCase(Ljava/lang/String;)Z
        istore_2 ; [bar]

        invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
        ldc " [ok]"

        iload_2 ; [bar]
        ifne CH_check_OK
        ;{
          pop
          ldc " [MISMATCH!]"
        ;}
CH_check_OK:
        invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
        iload_3 ; [quiet]
        invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V

        ifne CH_ret_1

        iload_2 ; [bar]
        ifne FE_no_mismatch
        ;{
          aconst_null
          astore 11 ; [body]

; +===========================================++
;  \   On cache file mismatch, delete file if ||
;   \  instructed to do so, otherwise quit.   ||
;    ^========================================++

          iload 5 ; [delete]
          ifne FE_delete
          ;{
            ldc "Cached file checksum could not be matched, will not delete!"
            goto error
          ;}
FE_delete:

          aload 9 ; [file]
          invokevirtual java/io/File.delete()Z
          ifne FE_delete_ok
          ;{
            ldc "Could not delete invalidated cached file!"
            goto error
          ;}

FE_delete_ok:
          ldc "Deleted invalidated cached file!"
          iload_3 ; [quiet]
          invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V
        ;}
FE_no_mismatch:
      ;}
FE_skip_check:
    ;}
FE_no_file:

; +===================================================++
;  \   If file was not sucessfully read and digested, ||
;   \  initiate download from the provided URL        ||
;    ^================================================++

    aload 11 ; [body]
    ifnonnull FD_already_read
    ;{
      ldc "Downloading file ("
      aload 8 ; [URL]
      invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
      ldc ") ..."
      invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V

      aconst_null
      astore_2 ; [bar]

FD_read:
      new java/io/BufferedInputStream
      dup
      aload 8 ; [URL]
      invokevirtual java/net/URL.openStream()Ljava/io/InputStream;
      invokenonvirtual java/io/BufferedInputStream.<init>(Ljava/io/InputStream;)V
      astore_2 ; [bar]

      new java/io/ByteArrayOutputStream
      dup
      invokenonvirtual java/io/ByteArrayOutputStream.<init>()V
      astore_1 ; [foo]

FD_loop:
      aload_2 ; [bar]
      invokevirtual java/io/InputStream.read()I
      dup

      iconst_m1
      if_icmpeq FD_loop_end
      ;{
        aload_1 ; [foo]
        swap
        invokevirtual java/io/ByteArrayOutputStream.write(I)V
        goto FD_loop
      ;}
FD_loop_end:
      pop

      aload_2 ; [bar]
      invokevirtual java/io/InputStream.close()V

      aload_1 ; [foo]
      invokevirtual java/io/ByteArrayOutputStream.toByteArray()[B
      astore 11 ; [body]

      goto FD_fin
    ;}

FD_error:
    aload_2 ; [bar]
    ifnull FD_skip_close
    ;{
      aload_2 ; [bar]
      invokevirtual java/io/InputStream.close()V
    ;}
FD_skip_close:
    ldc "File could not be downloaded"
    goto TH_error

; +============================================++
;  \   Calculate digest of the downloaded file ||
;    ^=========================================++

FD_fin:
    aload 10 ; [checkType]
    ifnull FD_skip_check
    ;{
        iconst_1
        ldc "File downloaded, calculated checksum: "
        goto CH_calc
CH_ret_1:

      iload_2 ; [bar]
      ifne FD_no_mismatch
      ;{
        ldc "Downloaded file does not match provided checksum, exiting!"
        goto error
      ;}
FD_no_mismatch:

; +==================================================++
;  \   Checksum was correct, write byte arry to file ||
;   ^================================================++

FD_skip_check:
      ldc "Writing file ("
      aload 9 ; [file]
      invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
      ldc ") ..."
      invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
      iload_3 ; [quiet]
      invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V

      aconst_null
      astore_1 ; [foo]

FO_write:
      new java/io/FileOutputStream
      dup
      aload 9 ; [file]
      invokenonvirtual java/io/FileOutputStream.<init>(Ljava/io/File;)V

      dup
      dup
      astore_1 ; [foo]
      aload 11 ; [body]
      invokevirtual java/io/FileOutputStream.write([B)V

      invokevirtual java/io/FileOutputStream.close()V
      goto FO_fin
FO_error:
      aload_1 ; [foo]
      ifnull FO_skip_close
      ;{
        aload_1 ; [foo]
        invokevirtual java/io/FileOutputStream.close()V
      ;}
FO_skip_close:

      ldc "File could not be written"
      goto TH_error

FO_fin:
    ;}
FD_already_read:

; +=============================================++
;  \   Find main class by locating the manifest ||
;   ^===========================================++

    aload 7 ; [mainClass]
    ifnonnull MC_located
    ;{
      new java/util/zip/ZipInputStream
      dup
      new java/io/ByteArrayInputStream
      dup
      aload 11 ; [body]
      invokenonvirtual java/io/ByteArrayInputStream.<init>([B)V
      invokenonvirtual java/util/zip/ZipInputStream.<init>(Ljava/io/InputStream;)V
      astore_1 ; [foo]

MC_seek:
      aload_1 ; [foo]
      invokevirtual java/util/zip/ZipInputStream.getNextEntry()Ljava/util/zip/ZipEntry;
      dup

      ifnonnull MC_seeking
      ;{
        pop
 MC_fail:
        ldc "Could not locate main class, exiting!"
        goto error
      ;}
MC_seeking:
      invokevirtual java/util/zip/ZipEntry.getName()Ljava/lang/String;
      ldc "META-INF/MANIFEST.MF"
      invokevirtual java/lang/String.equals(Ljava/lang/Object;)Z
      ifeq MC_seek

      new java/util/jar/Manifest
      dup
      dup
      invokenonvirtual java/util/jar/Manifest.<init>()V
      aload_1 ; [foo]
      invokevirtual java/util/jar/Manifest.read(Ljava/io/InputStream;)V

      invokevirtual java/util/jar/Manifest.getMainAttributes()Ljava/util/jar/Attributes;
      getstatic java/util/jar/Attributes$Name/MAIN_CLASS Ljava/util/jar/Attributes$Name;
      invokevirtual java/util/jar/Attributes.getValue(Ljava/util/jar/Attributes$Name;)Ljava/lang/String;
      astore 7 ; [mainClass]
      goto MC_test
    ;}

; +===================================================++
;  \   If main class is "",  do not run it (override) ||
;   ^=================================================++

MC_test:
    aload 7 ; [mainClass]
    ifnull MC_fail

MC_located:
    aload 7 ; [mainClass]
    invokevirtual java/lang/String.length()I
    ifne MC_load
    ;{
      ldc "Will not run main class, exiting!"
      goto OK_exit
    ;}
MC_load:

; +================================================++
;  \   Create a new URLClassLoader and load up the ||
;   \  main class parsed from the manifest         ||
;    ^=============================================++

    aload 7 ; [mainClass]
    iconst_1
    new java/net/URLClassLoader
    dup

    iconst_1
    anewarray java/net/URL
    dup

    iconst_0
    aload 9 ; [file]
    invokevirtual java/io/File.toURI()Ljava/net/URI;
    invokevirtual java/net/URI.toURL()Ljava/net/URL;
    aastore

    ldc "org.gruj.Vs"
    invokestatic java/lang/Class/forName(Ljava/lang/String;)Ljava/lang/Class;
    invokevirtual java/lang/Class/getClassLoader()Ljava/lang/ClassLoader;

    invokenonvirtual java/net/URLClassLoader.<init>([Ljava/net/URL;Ljava/lang/ClassLoader;)V
    invokestatic java/lang/Class.forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    ldc "main"
    iconst_1
    anewarray java/lang/Class
    dup

    iconst_0
    ldc "[Ljava.lang.String;"
    invokestatic java/lang/Class/forName(Ljava/lang/String;)Ljava/lang/Class;
    aastore

    invokevirtual java/lang/Class.getDeclaredMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;

    goto MC_fin

MC_crash:
    ldc "Could not load main class"
    goto TH_error

MC_fin:

; +==============================++
;  \   Invoke the class (koniec) ||
;   ^============================++

    ldc "Running main class: "
    aload 7 ; [mainClass]
    invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
    ldc " ..."
    invokestatic org/gruj/Vs.cat(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;
    iload_3 ; [quiet]
    invokestatic org/gruj/Vs.info(Ljava/lang/String;Z)V

    aconst_null
    iconst_1
    anewarray java/lang/Object
    dup

    iconst_0
    aload_0 ; [args]
    aastore
    invokevirtual java/lang/reflect/Method.invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;
    pop

    iconst_0
    goto DO_exit

.end method
