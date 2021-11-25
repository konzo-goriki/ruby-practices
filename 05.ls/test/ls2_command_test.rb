# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls2_command'

class Ls2Test < Minitest::Test
  TARGET_PATHNAME = Pathname('test/fixtures')

  def test_ls2
    expected = <<~TEXT.chomp
      10_UaQ4FZ6wFmgjrSbK.txt 18_SmnmcFmkAo.txt       6_cuGvwKyYdcgn5fr.txt
      11_gpnxJ.txt            19_Bp2ha7rLvBA.txt      7_yyHc985.txt
      12_B0ySF.txt            1_OUPQZ.txt             8_c68O.txt
      13_Emz27kuZ3zu.txt      20_4xDFDzEzGZ5Cmnu.txt  9_PyOO5FCJ.txt
      14_ADheMR.txt           2_l2XaS6FODT4A3yo3.txt  test_delete.sh
      15_AJGwIC.txt           3_zohOJ0CsPUrc.txt      test_dir1
      16_IeU8A.txt            4_UTPfaObDZz4.txt       test_setup.sh
      17_k1zj33PP.txt         5_q6IAF0SR9eOcC6w.txt
    TEXT
    assert_equal expected, run_ls(TARGET_PATHNAME)
  end

  def test_ls2_long_format
    # total 176
    # -rw-r--r--   1 konzo  staff   20 11 19 11:58 10_UaQ4FZ6wFmgjrSbK.txt
    # -rw-r--r--   1 konzo  staff    9 11 19 11:58 11_gpnxJ.txt
    # -rw-r--r--   1 konzo  staff    9 11 19 11:58 12_B0ySF.txt
    # -rw-r--r--   1 konzo  staff   15 11 19 11:58 13_Emz27kuZ3zu.txt
    # -rw-r--r--   1 konzo  staff   10 11 19 11:58 14_ADheMR.txt
    # -rw-r--r--   1 konzo  staff   10 11 19 11:58 15_AJGwIC.txt
    # -rw-r--r--   1 konzo  staff    9 11 19 11:58 16_IeU8A.txt
    # -rw-r--r--   1 konzo  staff   12 11 19 11:58 17_k1zj33PP.txt
    # -rw-r--r--   1 konzo  staff   14 11 19 11:58 18_SmnmcFmkAo.txt
    # -rw-r--r--   1 konzo  staff   15 11 19 11:58 19_Bp2ha7rLvBA.txt
    # -rw-r--r--   1 konzo  staff    8 11 19 11:58 1_OUPQZ.txt
    # -rw-r--r--   1 konzo  staff   19 11 19 11:58 20_4xDFDzEzGZ5Cmnu.txt
    # -rw-r--r--   1 konzo  staff   19 11 19 11:58 2_l2XaS6FODT4A3yo3.txt
    # -rw-r--r--   1 konzo  staff   15 11 19 11:58 3_zohOJ0CsPUrc.txt
    # -rw-r--r--   1 konzo  staff   14 11 19 11:58 4_UTPfaObDZz4.txt
    # -rw-r--r--   1 konzo  staff   18 11 19 11:58 5_q6IAF0SR9eOcC6w.txt
    # -rw-r--r--   1 konzo  staff   18 11 19 11:58 6_cuGvwKyYdcgn5fr.txt
    # -rw-r--r--   1 konzo  staff   10 11 19 11:58 7_yyHc985.txt
    # -rw-r--r--   1 konzo  staff    7 11 19 11:58 8_c68O.txt
    # -rw-r--r--   1 konzo  staff   11 11 19 11:58 9_PyOO5FCJ.txt
    # -rwxrwxrwx   1 konzo  staff   62 10 12 19:28 test_delete.sh
    # drwxr-xr-x  22 konzo  staff  704 11 19 11:58 test_dir1
    # -rwxrwxrwx   1 konzo  staff  460 11 19 11:56 test_setup.sh
    expected = `ls -l #{TARGET_PATHNAME}`.chomp
    assert_equal expected, run_ls(TARGET_PATHNAME, long_format: true)
  end

  def test_ls2_reverse
    expected = <<~TEXT.chomp
    test_setup.sh           4_UTPfaObDZz4.txt       16_IeU8A.txt
    test_dir1               3_zohOJ0CsPUrc.txt      15_AJGwIC.txt
    test_delete.sh          2_l2XaS6FODT4A3yo3.txt  14_ADheMR.txt
    9_PyOO5FCJ.txt          20_4xDFDzEzGZ5Cmnu.txt  13_Emz27kuZ3zu.txt
    8_c68O.txt              1_OUPQZ.txt             12_B0ySF.txt
    7_yyHc985.txt           19_Bp2ha7rLvBA.txt      11_gpnxJ.txt
    6_cuGvwKyYdcgn5fr.txt   18_SmnmcFmkAo.txt       10_UaQ4FZ6wFmgjrSbK.txt
    5_q6IAF0SR9eOcC6w.txt   17_k1zj33PP.txt
    TEXT
    assert_equal expected, run_ls(TARGET_PATHNAME, reverse: true)
  end

  def test_ls2_dot_match
    expected = <<~TEXT.chomp
    .                       17_k1zj33PP.txt         6_cuGvwKyYdcgn5fr.txt
    ..                      18_SmnmcFmkAo.txt       7_yyHc985.txt
    10_UaQ4FZ6wFmgjrSbK.txt 19_Bp2ha7rLvBA.txt      8_c68O.txt
    11_gpnxJ.txt            1_OUPQZ.txt             9_PyOO5FCJ.txt
    12_B0ySF.txt            20_4xDFDzEzGZ5Cmnu.txt  test_delete.sh
    13_Emz27kuZ3zu.txt      2_l2XaS6FODT4A3yo3.txt  test_dir1
    14_ADheMR.txt           3_zohOJ0CsPUrc.txt      test_setup.sh
    15_AJGwIC.txt           4_UTPfaObDZz4.txt
    16_IeU8A.txt            5_q6IAF0SR9eOcC6w.txt
    TEXT
    assert_equal expected, run_ls(TARGET_PATHNAME, dot_match: true)
  end

  def test_ls2_all_options
    expected = `ls -lar #{TARGET_PATHNAME}`.chomp
    assert_equal expected, run_ls(TARGET_PATHNAME, long_format: true, reverse: true, dot_match: true)
  end
end
