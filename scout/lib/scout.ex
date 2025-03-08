defmodule Scout do
  # This is amazing
  defp stringDist(first, second, map) do
    if Map.get(map, {first, second}) != nil do
      {Map.get(map, {first, second}), map}
    else
      case {String.length(first), String.length(second)} do
        {0, 0} -> {0, %{}}
        {x, 0} -> {x, %{}}
        {0, x} -> {x, %{}}
        _ -> case {String.split(first, ""), String.split(second, "")} do
          {[_ | a], [_ | b]} -> case {a, b} do
            {[x | f], [x | s]} ->
              fStr = List.to_string(f)
              sStr = List.to_string(s)
              {dist, map} = stringDist(fStr, sStr, map)
              map = Map.put(map, {fStr, sStr}, dist)
              {dist, map}
            {[x | f], [y | s]} ->
              fStr = List.to_string(f)
              sStr = List.to_string(s)
              lfStr = List.to_string([x | f])
              lsStr = List.to_string([y | s])

              {both, map} = stringDist fStr, sStr, map
              map = Map.put(map, {fStr, sStr}, both)
              if both == 0 do
                {1, map}
              else
                {fD, map} = stringDist fStr, lsStr, map
                map = Map.put(map, {fStr, lsStr}, fD)
                if fD == 0 do
                  {1, map}
                else
                  {sD, map} = stringDist lfStr, sStr, map
                  map = Map.put(map, {lfStr, sStr}, sD)
                  {1 + min(min(fD, sD), both), map}
                end
              end
          end
        end
      end
    end
  end

  def doLine(line, shouldoutput) do
    startTime = :os.system_time(:milli_seconds)
    getting = IO.gets("#{line}\n")
    diffTime = :os.system_time(:milli_seconds) - startTime
    {errors, _} = stringDist("#{line}\n", getting, %{})
    len = String.length(line) / :math.pow(2, errors)
    if shouldoutput do output({errors, diffTime, len}) end
    {errors, diffTime, len}
  end

  def output({errors, diffTime, len}) do
    frac = errors / cond do len < 1 -> 1 ; true -> len end
    IO.write(cond do
      frac < 0.05 -> IO.ANSI.green()
      frac < 0.15 -> IO.ANSI.yellow()
      true -> IO.ANSI.red()
    end <> "\tErrors: #{errors}\n\tc/s: #{len / diffTime * 1000}\n" <> IO.ANSI.reset())
  end

  def run(list) do
    case list do
      [] -> {0, 0, 0}
      [l | t] ->
        {err, time, len} = doLine(l, t != [])
        {err2, time2, len2} = run t
        {err + err2, time + time2, len + len2}
    end
  end

  def main(argv) do
    fString = argv
      |> case do
        [] -> ""
        [h | _] -> h
      end

    file = File.read(fString)
      |> case do
        {:error, _} -> ""
        {:ok, text} -> text
      end

    text = String.split(file, "\n")
      |> Enum.map(fn x -> String.split(x, "\r") end)
      |> List.flatten
      |> Enum.map(fn x -> String.trim(x) end)
      |> Enum.filter(fn x -> x != "" end)

    run(text) |> output
  end
end
