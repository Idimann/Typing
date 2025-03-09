defmodule Prime do
  defp findFirst x do
    case x do
      [] -> ""
      [c | t] -> case Integer.parse c do
        {x, ""} -> Integer.to_string(x)
        _ -> findFirst t
      end
    end
  end

  def advent list do
    line = fn x ->
      String.to_integer (findFirst String.split(x, "")) <>
        findFirst(x |> String.reverse |> String.split(""))
    end

    case list do
      [] -> 0
      [h | t] -> line.(h) + advent t
    end
  end
end

IO.puts Prime.advent ["1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet"]

# Lmfao solved in 2 minutes
