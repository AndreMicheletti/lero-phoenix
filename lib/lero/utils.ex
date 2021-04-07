defmodule Lero.Utils do

  def paginate(enumerable, page, offset) do
    if length(enumerable) <= offset do
      enumerable
    else
      Enum.slice(enumerable, page * offset, offset)
    end
  end

end
